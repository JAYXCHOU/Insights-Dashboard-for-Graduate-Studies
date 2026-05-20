#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Graduate Studies - Late Graduation Prediction Model
Input  : CSV exports จาก dbt gold layer (วางไว้ใน DATA_DIR)
Output : predictions_late_graduation.csv, feature_importance.csv

วิธีรัน:
    python ml/predict_late_graduation.py

ตั้งค่า folder ที่วาง CSV:
    set GRAD_DATA_DIR=C:/path/to/gold/csv/folder   (Windows)
    export GRAD_DATA_DIR=/path/to/gold/csv/folder  (Mac/Linux)

ไฟล์ CSV ที่ต้องการ (export จาก gold layer):
    dim_student.csv
    fact_sum_period.csv
    fact_sum_milestone.csv
    fact_scholar.csv
    fact_nonstu_status.csv
"""

import logging
import os
import sys
import warnings

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.metrics import (
    classification_report, confusion_matrix,
    roc_auc_score, accuracy_score, f1_score,
    precision_score, recall_score,
)
from sklearn.model_selection import StratifiedKFold, cross_val_score, cross_val_predict
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

warnings.filterwarnings("ignore")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    stream=sys.stdout,
)
logger = logging.getLogger(__name__)

# ============================================================
# CONFIGURATION
# ============================================================
# Default = data/gold/ ในโปรเจกต์ (วาง CSV ไว้ที่นี่แล้วรันได้เลย)
_PROJECT_ROOT    = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_DATA_DIR = os.path.join(_PROJECT_ROOT, "data", "gold")
DATA_DIR         = os.environ.get("GRAD_DATA_DIR", DEFAULT_DATA_DIR)

GRADUATED_STATUS = "สำเร็จการศึกษา"
ACTIVE_STATUSES  = ["กำลังศึกษา", "รอเผยแพร่ผลงานวิจัย"]

# Milestone IDs ที่สร้าง per-form features
# 2=สอบโครงร่าง  3=อนุมัติหัวข้อ  4=สอบวิทยานิพนธ์  5=สอบวัดคุณสมบัติ(PhD)
MILESTONE_KEY_IDS = ["2", "3", "4", "5"]

# ============================================================
# 1. LOAD DATA
# ============================================================
def load_data(data_dir: str) -> dict:
    required = {
        "student":   "dim_student.csv",
        "period":    "fact_sum_period.csv",
        "milestone": "fact_sum_milestone.csv",
        "scholar":   "fact_scholar.csv",
        "nonstu":    "fact_nonstu_status.csv",
    }
    dfs = {}
    for key, fname in required.items():
        path = os.path.join(data_dir, fname)
        if not os.path.exists(path):
            raise FileNotFoundError(f"ไม่พบไฟล์ {fname} ใน {data_dir}")
        dfs[key] = pd.read_csv(path, encoding="utf-8-sig", low_memory=False)
        logger.info("Loaded %-35s -> %5d rows", fname, len(dfs[key]))

    return dfs

# ============================================================
# 2. FEATURE ENGINEERING
# ============================================================
def engineer_period_features(period_df: pd.DataFrame) -> pd.DataFrame:
    df = period_df.copy()
    df["start_date"]    = pd.to_datetime(df["start_date"], dayfirst=False, errors="coerce")
    df["end_date"]      = pd.to_datetime(df["end_date"],   dayfirst=False, errors="coerce")
    df["duration_days"] = (df["end_date"] - df["start_date"]).dt.days.clip(lower=0)
    pivot = df.pivot_table(
        index="stu_id", columns="period_id",
        values="duration_days", aggfunc="first",
    ).reset_index()
    pivot.columns = ["stu_id"] + [f"phase{int(c)}_days" for c in pivot.columns[1:]]
    return pivot


def engineer_milestone_features(milestone_df: pd.DataFrame) -> pd.DataFrame:
    """
    Aggregate: milestone_passed, milestone_avg_actions
    Per key milestone (2,3,4,5): m{id}_passed, m{id}_days_to_pass, m{id}_attempts
    """
    df = milestone_df.copy()
    df["ID_form"]      = df["ID_form"].astype(str).str.strip()
    df["submit_date"]  = pd.to_datetime(df["submit_date"], dayfirst=False, errors="coerce")
    df["pass_date"]    = pd.to_datetime(df["pass_date"],   dayfirst=False, errors="coerce")
    df["days_to_pass"] = (df["pass_date"] - df["submit_date"]).dt.days.clip(lower=0)
    df["is_passed"]    = df["pass_date"].notna().astype(int)

    agg = df.groupby("stu_id").agg(
        milestone_passed=("is_passed", "sum"),
        milestone_avg_actions=("count_action", "mean"),
    ).reset_index()

    for form_id in MILESTONE_KEY_IDS:
        sub = df[df["ID_form"] == form_id]
        if sub.empty:
            agg[f"m{form_id}_passed"]       = 0
            agg[f"m{form_id}_days_to_pass"] = np.nan
            agg[f"m{form_id}_attempts"]     = 0
            continue
        sub_agg = sub.groupby("stu_id").agg(
            **{f"m{form_id}_passed":       ("is_passed",    "max")},
            **{f"m{form_id}_days_to_pass": ("days_to_pass", "first")},
            **{f"m{form_id}_attempts":     ("count_action", "sum")},
        ).reset_index()
        agg = agg.merge(sub_agg, on="stu_id", how="left")
        agg[f"m{form_id}_passed"]   = agg[f"m{form_id}_passed"].fillna(0).astype(int)
        agg[f"m{form_id}_attempts"] = agg[f"m{form_id}_attempts"].fillna(0)

    return agg


def engineer_scholar_features(scholar_df: pd.DataFrame) -> pd.DataFrame:
    """has_scholarship, total_scholarship"""
    agg = scholar_df.groupby("stu_id").agg(
        _count=("Sch_ID", "count"),
        total_scholarship=("Amount", "sum"),
    ).reset_index()
    agg["has_scholarship"] = (agg["_count"] > 0).astype(int)
    agg.drop(columns=["_count"], inplace=True)
    return agg


def engineer_leave_features(nonstu_df: pd.DataFrame) -> pd.DataFrame:
    """nonstu_record_count, total_leave_terms, has_medical_leave"""
    df = nonstu_df.copy()
    agg = df.groupby("stu_id").agg(
        nonstu_record_count=("nstu_id", "count"),
    ).reset_index()

    leave_terms = (
        df.dropna(subset=["snon_year", "snon_term"])
        .drop_duplicates(subset=["stu_id", "snon_year", "snon_term"])
        .groupby("stu_id").size()
        .reset_index(name="total_leave_terms")
    )

    medical_kw = ["ป่วย", "สุขภาพ", "medical", "health"]
    df["_is_medical"] = (
        df["nstu_status_type_thai"].fillna("")
        .str.contains("|".join(medical_kw), case=False)
        .astype(int)
    )
    medical_agg = df.groupby("stu_id").agg(
        has_medical_leave=("_is_medical", "max")
    ).reset_index()

    agg = agg.merge(leave_terms,  on="stu_id", how="left")
    agg = agg.merge(medical_agg,  on="stu_id", how="left")
    agg["total_leave_terms"] = agg["total_leave_terms"].fillna(0)
    agg["has_medical_leave"] = agg["has_medical_leave"].fillna(0).astype(int)
    return agg


# ============================================================
# FEATURE COLUMNS
# ============================================================
BASE_FEATURE_COLS = [
    # Degree & program
    "is_phd",                      # 1=PhD, 0=Master
    "is_international",            # 1=นานาชาติ
    "Study_Type_enc",              # Plan A/B (encoded)
    "max_year_filled",             # ระยะเวลาสูงสุด (ปี)
    "Bench_id",                    # เกณฑ์การประเมิน
    "Brn_ID",                      # รหัสสาขาวิชา
    "fac_id",                      # รหัสคณะ
    "groupN_id",                   # กลุ่มสาขา
    # Demographics
    "is_male",                     # 1=ชาย
    "is_thai",                     # 1=สัญชาติไทย
    "is_thai_thesis",              # 1=วิทยานิพนธ์ภาษาไทย
    "age_at_admission",            # อายุตอนเข้า (ปี)
    # Academic
    "stu_gpa_old",                 # GPA เดิม
    "Grad_mean_Sum",               # GPA สะสมปัจจุบัน
    # Employment
    "Job_Status_enc",              # สถานะการทำงาน (encoded)
    # Scholarship
    "has_scholarship",             # 1=มีทุน
    "total_scholarship",           # มูลค่าทุนรวม
    # Leave
    "nonstu_record_count",         # จำนวน non-student records
    "total_leave_terms",           # จำนวนเทอมที่ลา
    "has_medical_leave",           # 1=เคยลาป่วย
    # Milestone aggregate
    "milestone_passed",            # จำนวน milestone ที่ผ่าน
    "milestone_avg_actions",       # เฉลี่ยครั้งต่อ milestone
    # Per-milestone (key forms)
    "m2_passed", "m2_days_to_pass", "m2_attempts",  # สอบโครงร่าง
    "m3_passed", "m3_days_to_pass", "m3_attempts",  # อนุมัติหัวข้อ
    "m4_passed", "m4_days_to_pass", "m4_attempts",  # สอบวิทยานิพนธ์
    "m5_passed", "m5_days_to_pass", "m5_attempts",  # วัดคุณสมบัติ (PhD)
]

PHASE_COLS = ["phase1_days", "phase2_days", "phase3_days", "phase4_days"]


def build_features(
    student_df: pd.DataFrame,
    period_feat: pd.DataFrame,
    milestone_feat: pd.DataFrame,
    scholar_feat: pd.DataFrame,
    leave_feat: pd.DataFrame,
) -> tuple:
    df = student_df.copy()

    # Merge all feature tables
    df = df.merge(period_feat,    on="stu_id", how="left")
    df = df.merge(milestone_feat, on="stu_id", how="left")
    df = df.merge(scholar_feat,   on="stu_id", how="left")
    df = df.merge(leave_feat,     on="stu_id", how="left")

    # Binary encoding
    df["is_phd"]           = (df["deg_lev_id"].astype(str).str.strip() == "D").astype(int)
    df["is_international"] = (df["Cur_Type"].astype(str).str.strip() == "I").astype(int)
    df["is_male"]          = (df["stu_sex"].astype(str).str.strip() == "M").astype(int)
    df["is_thai"]          = (pd.to_numeric(df["nat_id"], errors="coerce") == 1).astype(int)
    df["is_thai_thesis"]   = (
        df["thesis_lang"].astype(str).str.strip().str.upper() == "T"
    ).astype(int)

    # Categorical encoding
    df["Study_Type_enc"] = pd.Categorical(df["Study_Type"].astype(str).str.strip()).codes
    df["Job_Status_enc"] = pd.Categorical(df["Job_Status"].astype(str).str.strip()).codes

    # Numeric columns
    for col in ["stu_gpa_old", "Grad_mean_Sum", "fac_id", "groupN_id", "Bench_id", "Brn_ID"]:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    # Age at admission
    birth_year = pd.to_datetime(df["stu_birth"], errors="coerce").dt.year
    df["age_at_admission"] = pd.to_numeric(df["stu_adm_year"], errors="coerce") - birth_year

    # max_year — ไม่ fill NULL, ปล่อยให้ create_target() drop เอง
    df["max_year_filled"] = pd.to_numeric(df["max_year"], errors="coerce")

    # Fill defaults for join columns
    df["has_scholarship"]     = df["has_scholarship"].fillna(0).astype(int)
    df["total_scholarship"]   = df["total_scholarship"].fillna(0)
    df["nonstu_record_count"] = df["nonstu_record_count"].fillna(0)
    df["total_leave_terms"]          = df["total_leave_terms"].fillna(0)
    df["has_medical_leave"]          = df["has_medical_leave"].fillna(0)

    # Final feature list (add phase cols if present)
    feature_cols = list(BASE_FEATURE_COLS)
    for col in PHASE_COLS:
        if col in df.columns:
            feature_cols.append(col)

    return df, feature_cols


def drop_null_features(X_train: pd.DataFrame, feature_cols: list) -> list:
    null_cols = [c for c in feature_cols if X_train[c].isnull().all()]
    if null_cols:
        logger.warning("ตัด feature ที่ไม่มีข้อมูลใน train set: %s", null_cols)
    return [c for c in feature_cols if c not in null_cols]

# ============================================================
# 3. TARGET VARIABLE
# ============================================================
def create_target(grad_df: pd.DataFrame) -> pd.DataFrame:
    df = grad_df.copy()
    df["stu_comp_year"] = pd.to_numeric(df["stu_comp_year"], errors="coerce")
    df["stu_adm_year"]  = pd.to_numeric(df["stu_adm_year"],  errors="coerce")
    df["years_taken"]   = df["stu_comp_year"] - df["stu_adm_year"]

    # Drop NULL max_year (ไม่สามารถสร้าง label ได้)
    before = len(df)
    df = df[df["max_year_filled"].notna()].copy()
    if len(df) < before:
        logger.info("Drop %d rows ที่ max_year เป็น NULL (BI ยังเห็นได้, ML ต้อง drop)", before - len(df))

    # Drop anomaly years_taken
    before2 = len(df)
    df = df[(df["years_taken"] >= 0) & (df["years_taken"] <= 15)].copy()
    if len(df) < before2:
        logger.warning("กรอง %d rows ที่ years_taken ผิดปกติออก", before2 - len(df))

    df["late"] = (df["years_taken"] > df["max_year_filled"]).astype(int)
    counts = df["late"].value_counts()
    logger.info("Target: ตามแผน=%d  จบช้า=%d  Late rate=%.1f%%",
                counts.get(0, 0), counts.get(1, 0), df["late"].mean() * 100)
    return df

# ============================================================
# 4. TRAIN MODEL
# ============================================================
def train_model(X_train: pd.DataFrame, y_train: pd.Series) -> tuple:
    """Returns (pipeline, cv_auc_mean)"""
    pipeline = Pipeline([
        ("imputer", SimpleImputer(strategy="median")),
        ("scaler",  StandardScaler()),
        ("model",   RandomForestClassifier(
            n_estimators=200, max_depth=6, min_samples_leaf=3,
            class_weight="balanced", random_state=42, n_jobs=-1,
        )),
    ])
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

    # ── Cross-validation metrics ──────────────────────────────────────────
    metrics = {
        "ROC-AUC":  "roc_auc",
        "Accuracy": "accuracy",
        "F1":       "f1",
        "Precision":"precision",
        "Recall":   "recall",
    }
    cv_results = {}
    for name, scoring in metrics.items():
        scores = cross_val_score(pipeline, X_train, y_train, cv=cv, scoring=scoring)
        cv_results[name] = scores

    cv_auc_mean = float(cv_results["ROC-AUC"].mean())

    # ── Print evaluation summary ──────────────────────────────────────────
    sep = "=" * 55
    print(f"\n{sep}")
    print("  MODEL EVALUATION  (5-Fold Stratified Cross-Validation)")
    print(sep)
    print(f"  {'Metric':<12}  {'Mean':>7}  {'Std':>7}  {'Min':>7}  {'Max':>7}")
    print(f"  {'-'*12}  {'-'*7}  {'-'*7}  {'-'*7}  {'-'*7}")
    for name, scores in cv_results.items():
        print(f"  {name:<12}  {scores.mean():>7.3f}  {scores.std():>7.3f}  "
              f"{scores.min():>7.3f}  {scores.max():>7.3f}")
    print(sep)

    # ── Confusion matrix จาก CV predictions ──────────────────────────────
    y_cv_pred = cross_val_predict(pipeline, X_train, y_train, cv=cv)
    cm = confusion_matrix(y_train, y_cv_pred)
    print("\n  Confusion Matrix (CV predictions):")
    print(f"  {'':>16} Predicted: ตามแผน  Predicted: จบช้า")
    print(f"  {'Actual: ตามแผน':>16}  {cm[0,0]:>16}  {cm[0,1]:>16}")
    print(f"  {'Actual: จบช้า':>16}  {cm[1,0]:>16}  {cm[1,1]:>16}")

    tn, fp, fn, tp = cm.ravel()
    print(f"\n  True Positive  (จบช้า ทำนายถูก) : {tp:>5}")
    print(f"  False Positive (ตามแผน ทำนายผิด): {fp:>5}  ← แจ้งเตือนเกิน")
    print(f"  False Negative (จบช้า ทำนายพลาด): {fn:>5}  ← พลาดเคส")
    print(f"  True Negative  (ตามแผน ทำนายถูก): {tn:>5}")
    print(sep)

    # ── Class distribution ────────────────────────────────────────────────
    n_late = int(y_train.sum())
    n_total = len(y_train)
    print(f"\n  Train set: {n_total} นักศึกษา  |  "
          f"จบช้า {n_late} ({n_late/n_total*100:.1f}%)  |  "
          f"ตามแผน {n_total-n_late} ({(n_total-n_late)/n_total*100:.1f}%)")
    print(f"{sep}\n")

    # ── Fit final model ───────────────────────────────────────────────────
    pipeline.fit(X_train, y_train)
    return pipeline, cv_auc_mean

# ============================================================
# 5. FEATURE IMPORTANCE
# ============================================================
def get_feature_importance(pipeline, feature_cols: list) -> pd.DataFrame:
    rf = pipeline.named_steps["model"]
    fi = pd.DataFrame({
        "feature":    feature_cols,
        "importance": rf.feature_importances_,
    }).sort_values("importance", ascending=False).reset_index(drop=True)
    logger.info("Top 15 Features:\n%s", fi.head(15).to_string(index=False))
    return fi

# ============================================================
# 6. PREDICT ACTIVE STUDENTS
# ============================================================
def predict_active_students(pipeline, active_df: pd.DataFrame, feature_cols: list) -> pd.DataFrame:
    X_test = active_df[feature_cols]
    probs  = pipeline.predict_proba(X_test)[:, 1]
    preds  = pipeline.predict(X_test)
    result = active_df[[
        "stu_id", "sta_pres_des", "deg_lev_id",
        "stu_adm_year", "max_year_filled", "Grad_mean_Sum", "fac_id", "Brn_ID",
    ]].copy()
    result["predicted_late"]   = preds
    result["prob_late"]        = np.round(probs, 4)
    result["prediction_label"] = result["predicted_late"].map({0: "ตามแผน", 1: "จบช้า"})
    result["risk_level"] = pd.cut(
        result["prob_late"], bins=[0, 0.3, 0.6, 1.0],
        labels=["Low Risk", "Medium Risk", "High Risk"], include_lowest=True,
    )
    return result.sort_values("prob_late", ascending=False).reset_index(drop=True)

# ============================================================
# MAIN
# ============================================================
def main(data_dir: str = DATA_DIR) -> dict:
    """
    รัน ML pipeline ทั้งหมด
    data_dir : folder ที่วาง CSV files จาก gold layer
    """
    logger.info("=" * 60)
    logger.info("  Graduate Late Graduation Prediction Model")
    logger.info("  DATA_DIR: %s", data_dir)
    logger.info("=" * 60)

    # 1. Load
    logger.info("[1] Loading CSV data...")
    dfs = load_data(data_dir)

    # 2. Feature engineering
    logger.info("[2] Engineering features...")
    period_feat    = engineer_period_features(dfs["period"])
    milestone_feat = engineer_milestone_features(dfs["milestone"])
    scholar_feat   = engineer_scholar_features(dfs["scholar"])
    leave_feat     = engineer_leave_features(dfs["nonstu"])

    # 3. Build feature matrix
    logger.info("[3] Building master feature matrix...")
    full_df, feature_cols = build_features(
        dfs["student"], period_feat, milestone_feat,
        scholar_feat, leave_feat,
    )

    # 4. Split graduated vs active
    grad_df   = full_df[full_df["sta_pres_des"] == GRADUATED_STATUS].copy()
    active_df = full_df[full_df["sta_pres_des"].isin(ACTIVE_STATUSES)].copy()
    logger.info("Train (graduated)     : %4d students", len(grad_df))
    logger.info("Test  (active/waiting): %4d students", len(active_df))

    # 5. Target variable
    logger.info("[4] Creating target variable...")
    grad_df      = create_target(grad_df)
    feature_cols = drop_null_features(grad_df[feature_cols], feature_cols)
    X_train      = grad_df[feature_cols]
    y_train      = grad_df["late"]
    logger.info("Features used (%d): %s", len(feature_cols), feature_cols)

    # 6. Train + evaluate
    logger.info("[5] Training model...")
    model, cv_auc_mean = train_model(X_train, y_train)

    # 7. Feature importance
    logger.info("[6] Feature Importance:")
    fi     = get_feature_importance(model, feature_cols)
    out_fi = os.path.join(data_dir, "feature_importance.csv")
    fi.to_csv(out_fi, index=False, encoding="utf-8-sig")
    logger.info("Saved -> %s", out_fi)

    # 8. Predict active students
    result_summary = {
        "cv_auc_mean":   cv_auc_mean,
        "n_high_risk":   0,
        "n_medium_risk": 0,
        "n_low_risk":    0,
        "output_path":   None,
    }
    if len(active_df) > 0:
        logger.info("[7] Predicting active students...")
        predictions = predict_active_students(model, active_df, feature_cols)
        out_pred = os.path.join(data_dir, "predictions_late_graduation.csv")
        predictions.to_csv(out_pred, index=False, encoding="utf-8-sig")
        logger.info("Saved -> %s", out_pred)
        rc = predictions["risk_level"].value_counts()
        result_summary.update({
            "n_high_risk":   int(rc.get("High Risk",   0)),
            "n_medium_risk": int(rc.get("Medium Risk", 0)),
            "n_low_risk":    int(rc.get("Low Risk",    0)),
            "output_path":   out_pred,
        })
        print("\n=== Prediction Summary ===")
        print(f"  High Risk   : {result_summary['n_high_risk']:>5} students")
        print(f"  Medium Risk : {result_summary['n_medium_risk']:>5} students")
        print(f"  Low Risk    : {result_summary['n_low_risk']:>5} students")
        print(f"  Output      : {out_pred}")
        print("=" * 27)
    else:
        logger.warning("[7] No active students found.")

    logger.info("Done.")
    return result_summary


if __name__ == "__main__":
    main()
