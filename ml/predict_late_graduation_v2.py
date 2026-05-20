#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Graduate Late Graduation Prediction  —  Version 2
==================================================

สิ่งที่เปลี่ยนจาก v1:
  ✅ กำหนด "จุดทำนาย" ชัดเจน = หลังสอบ Proposal ผ่าน (m2)
  ✅ ใช้เฉพาะข้อมูลที่รู้ได้ ณ จุดนั้น (ไม่มี data leakage)
  ✅ เปรียบเทียบ 3 โมเดล แล้วเลือกตัวที่ดีที่สุด
  ✅ วัด Recall เป็นหลัก (ไม่อยากพลาดนักศึกษาที่จะจบช้า)

แก้ไขล่าสุด (v2.1):
  🔧 แก้ลำดับ fit/cross_val_predict — โมเดล production ใช้ข้อมูล 100%
  🔧 ตัด proposal_passed ออก (constant = 1 หลัง filter)
  🔧 ตัด has_medical_leave ออก (ข้อมูล nonstu ไม่มี medical keyword)
  🔧 Cap stu_gpa_old > 4.0 → NaN (outlier dirty data)
  🔧 Cap Grad_mean_Sum == 0 → NaN (GPA 0 ไม่มีจริง)
  🔧 Cap proposal/topic days_to_pass > 365 → 365 (outlier สูงสุด 3,631 วัน)
  🔧 ใช้ cross_validate แทน 4x cross_val_score (เร็วขึ้น 4x)

วิธีรัน:
    python ml/predict_late_graduation_v2.py

ไฟล์ CSV ที่ต้องการ (วางไว้ใน data/gold/):
    dim_student.csv
    fact_sum_milestone.csv
    fact_scholar.csv
    fact_nonstu_status.csv
"""

import os
import warnings

import numpy as np
import pandas as pd

from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import StratifiedKFold, cross_validate, cross_val_predict
from sklearn.metrics import confusion_matrix

warnings.filterwarnings("ignore")

# ============================================================
# ตั้งค่า folder ที่วาง CSV
# ============================================================
_PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.environ.get("GRAD_DATA_DIR", os.path.join(_PROJECT_ROOT, "data", "gold"))

GRADUATED_STATUS = "สำเร็จการศึกษา"
ACTIVE_STATUSES  = ["กำลังศึกษา", "รอเผยแพร่ผลงานวิจัย"]

# ค่า cap สำหรับ outlier
GPA_MAX          = 4.0    # GPA สูงสุดที่ถูกต้อง (> 4.0 = dirty data)
DAYS_TO_PASS_MAX = 365    # วันสูงสุดที่สมเหตุสมผล (> 365 = outlier)


# ============================================================
# STEP 1 — โหลดข้อมูล
# ============================================================
def load_data(data_dir):
    files = {
        "student":   "dim_student.csv",
        "milestone": "fact_sum_milestone.csv",
        "scholar":   "fact_scholar.csv",
        "nonstu":    "fact_nonstu_status.csv",
    }
    dfs = {}
    for key, fname in files.items():
        path = os.path.join(data_dir, fname)
        if not os.path.exists(path):
            raise FileNotFoundError(f"ไม่พบไฟล์ {fname} ใน {data_dir}")
        dfs[key] = pd.read_csv(path, encoding="utf-8-sig", low_memory=False)
        print(f"  โหลด {fname:<35} → {len(dfs[key]):>6,} แถว")
    return dfs


# ============================================================
# STEP 2 — สร้าง Features
#
# ใช้เฉพาะข้อมูลที่รู้ได้ ณ วันที่สอบ Proposal ผ่าน ได้แก่:
#   - ข้อมูลพื้นฐานนักศึกษา (สัญชาติ, เพศ, หลักสูตร ฯลฯ)
#   - GPA (cleaned: cap ที่ 4.0, treat 0 เป็น NaN)
#   - ทุนการศึกษา
#   - ประวัติสถานะ non-student (พ้นสภาพชั่วคราว/ลาออกบางส่วน)
#   - ผลสอบ Proposal (m2) และ อนุมัติหัวข้อ (m3)
#
# ไม่ใช้: phase3_days, phase4_days, m4, m5
# เหตุผล: สิ่งเหล่านี้เกิดขึ้นหลังจากสอบ Proposal ไปแล้ว
# ============================================================
def build_features(student_df, milestone_df, scholar_df, nonstu_df):

    df = student_df.copy()

    # ── ข้อมูลพื้นฐาน ──────────────────────────────────────────
    df["is_phd"]           = (df["deg_lev_id"].astype(str).str.strip().str.upper() == "D").astype(int)
    df["is_international"] = (df["Cur_Type"].astype(str).str.strip() == "I").astype(int)
    df["is_male"]          = (df["stu_sex"].astype(str).str.strip() == "M").astype(int)
    df["is_thai"]          = (pd.to_numeric(df["nat_id"], errors="coerce") == 1).astype(int)
    df["is_thai_thesis"]   = (df["thesis_lang"].astype(str).str.strip().str.upper() == "T").astype(int)
    df["Study_Type_enc"]   = pd.Categorical(df["Study_Type"].astype(str).str.strip()).codes
    df["Job_Status_enc"]   = pd.Categorical(df["Job_Status"].astype(str).str.strip()).codes
    df["max_year_filled"]  = pd.to_numeric(df["max_year"], errors="coerce")

    # อายุตอนเข้าเรียน
    df["age_at_admission"] = (
        pd.to_numeric(df["stu_adm_year"], errors="coerce")
        - pd.to_datetime(df["stu_birth"], errors="coerce").dt.year
    )

    # แปลงคอลัมน์ตัวเลข
    for col in ["fac_id", "Brn_ID", "groupN_id", "Bench_id"]:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    # GPA — cap outlier และ treat 0 เป็น NaN
    # stu_gpa_old > 4.0 = dirty data (พบสูงสุด 347), Grad_mean_Sum = 0 ไม่มีจริง
    gpa_old = pd.to_numeric(df["stu_gpa_old"], errors="coerce")
    df["stu_gpa_old"]    = gpa_old.where(gpa_old.between(0.01, GPA_MAX), other=np.nan)

    grad_gpa = pd.to_numeric(df["Grad_mean_Sum"], errors="coerce")
    df["Grad_mean_Sum"]  = grad_gpa.where(grad_gpa > 0, other=np.nan)

    # ── Proposal (m2) และ Topic Approval (m3) ──────────────────
    ms = milestone_df.copy()
    ms["ID_form"]      = ms["ID_form"].astype(str).str.strip()
    ms["submit_date"]  = pd.to_datetime(ms["submit_date"], errors="coerce")
    ms["pass_date"]    = pd.to_datetime(ms["pass_date"],   errors="coerce")
    ms["days_to_pass"] = (ms["pass_date"] - ms["submit_date"]).dt.days.clip(lower=0)
    ms["is_passed"]    = ms["pass_date"].notna().astype(int)

    # m2 = สอบโครงร่าง (Proposal Defense)
    # m3 = อนุมัติหัวข้อ (Topic Approval)
    for form_id, label in [("2", "proposal"), ("3", "topic")]:
        sub = ms[ms["ID_form"] == form_id].groupby("stu_id").agg(
            **{f"{label}_passed":       ("is_passed",    "max")},
            **{f"{label}_days_to_pass": ("days_to_pass", "first")},
            **{f"{label}_attempts":     ("count_action", "sum")},
        ).reset_index()
        df = df.merge(sub, on="stu_id", how="left")
        df[f"{label}_passed"]   = df[f"{label}_passed"].fillna(0).astype(int)
        df[f"{label}_attempts"] = df[f"{label}_attempts"].fillna(0)

        # Cap days_to_pass — ค่า > 365 วัน ถือเป็น outlier
        days_col = f"{label}_days_to_pass"
        df[days_col] = df[days_col].clip(upper=DAYS_TO_PASS_MAX)

    # ── ทุนการศึกษา ────────────────────────────────────────────
    sch = scholar_df.groupby("stu_id").agg(
        _count=("Sch_ID", "count"),
        total_scholarship=("Amount", "sum"),
    ).reset_index()
    sch["has_scholarship"] = (sch["_count"] > 0).astype(int)
    sch.drop(columns=["_count"], inplace=True)
    df = df.merge(sch, on="stu_id", how="left")
    df["has_scholarship"]   = df["has_scholarship"].fillna(0).astype(int)
    df["total_scholarship"] = df["total_scholarship"].fillna(0)

    # ── ประวัติสถานะ non-student ───────────────────────────────
    # หมายเหตุ: fact_nonstu_status เก็บสถานะพ้นสภาพ/ลาออก/สละสิทธิ์
    # ใช้เพื่อวัดว่านักศึกษาเคยมีปัญหาสถานะการเรียนหรือไม่
    ns = nonstu_df.copy()

    leave_count = ns.groupby("stu_id").agg(
        nonstu_record_count=("nstu_id", "count"),
    ).reset_index()

    leave_terms = (
        ns.dropna(subset=["snon_year", "snon_term"])
        .drop_duplicates(subset=["stu_id", "snon_year", "snon_term"])
        .groupby("stu_id").size()
        .reset_index(name="total_leave_terms")
    )

    df = df.merge(leave_count, on="stu_id", how="left")
    df = df.merge(leave_terms, on="stu_id", how="left")
    df["nonstu_record_count"] = df["nonstu_record_count"].fillna(0)
    df["total_leave_terms"]   = df["total_leave_terms"].fillna(0)

    return df


# Features ที่ใช้ทั้งหมด (24 ตัว, รู้ได้ ณ จุดสอบ Proposal ผ่าน)
# หมายเหตุ: ตัด proposal_passed (constant=1 หลัง filter) และ has_medical_leave (ไม่มีข้อมูล)
FEATURE_COLS = [
    # ── หลักสูตร ──
    "is_phd",            # ปริญญาเอก = 1, โท = 0
    "is_international",  # นานาชาติ = 1
    "Study_Type_enc",    # แผน ก/ข (แปลงเป็นตัวเลข)
    "max_year_filled",   # ปีสูงสุดที่เรียนได้
    "fac_id",            # คณะ
    "Brn_ID",            # สาขาวิชา
    "groupN_id",         # กลุ่มสาขา
    "Bench_id",          # เกณฑ์ประเมิน
    # ── ส่วนตัว ──
    "is_male",           # เพศชาย = 1
    "is_thai",           # สัญชาติไทย = 1
    "is_thai_thesis",    # วิทยานิพนธ์ภาษาไทย = 1
    "age_at_admission",  # อายุตอนเข้า (ปี)
    # ── วิชาการ ──
    "stu_gpa_old",       # GPA เดิม (cleaned: cap 4.0, 0→NaN)
    "Grad_mean_Sum",     # GPA สะสมปัจจุบัน (cleaned: 0→NaN)
    # ── การทำงาน ──
    "Job_Status_enc",    # สถานะการทำงาน (แปลงเป็นตัวเลข)
    # ── ทุน ──
    "has_scholarship",   # มีทุน = 1
    "total_scholarship", # มูลค่าทุนรวม (บาท)
    # ── ประวัติสถานะ non-student ──
    "nonstu_record_count",  # จำนวนครั้งที่มีสถานะ non-student
    "total_leave_terms",    # จำนวนเทอมที่มีสถานะ non-student
    # ── Proposal Defense (m2) ← ตัวชี้วัดสำคัญ ──
    "proposal_days_to_pass", # ใช้เวลากี่วันกว่าจะผ่าน (cap 365)
    "proposal_attempts",     # สอบกี่ครั้งถึงผ่าน
    # ── Topic Approval (m3) ──
    "topic_passed",          # อนุมัติหัวข้อแล้ว = 1
    "topic_days_to_pass",    # ใช้เวลากี่วัน (cap 365)
    "topic_attempts",        # ยื่นกี่ครั้ง
]


# ============================================================
# STEP 3 — สร้าง Target Variable
#
# late = 1  →  จบช้า  (ใช้เวลาเรียนมากกว่าที่กำหนด)
# late = 0  →  จบทัน
# ============================================================
def create_target(grad_df):
    df = grad_df.copy()
    df["stu_comp_year"] = pd.to_numeric(df["stu_comp_year"], errors="coerce")
    df["stu_adm_year"]  = pd.to_numeric(df["stu_adm_year"],  errors="coerce")
    df["years_taken"]   = df["stu_comp_year"] - df["stu_adm_year"]

    # ลบแถวที่ไม่มี max_year (ไม่รู้ว่าควรจบในกี่ปี)
    df = df[df["max_year_filled"].notna()].copy()

    # ลบข้อมูลผิดปกติ (เรียนน้อยกว่า 0 หรือมากกว่า 15 ปี)
    df = df[(df["years_taken"] >= 0) & (df["years_taken"] <= 15)].copy()

    df["late"] = (df["years_taken"] > df["max_year_filled"]).astype(int)

    n_late  = int(df["late"].sum())
    n_total = len(df)
    print(f"  จบช้า: {n_late:,} คน ({n_late/n_total*100:.1f}%)")
    print(f"  จบทัน: {n_total - n_late:,} คน ({(n_total - n_late)/n_total*100:.1f}%)")
    return df


# ============================================================
# STEP 4 — เปรียบเทียบ 3 โมเดล
#
# โมเดลที่ทดสอบ:
#   1. Logistic Regression  — เรียบง่าย อธิบายได้ง่ายที่สุด
#   2. Random Forest        — Ensemble ที่แกร่ง
#   3. Gradient Boosting    — มักได้ผลดีที่สุดในทางปฏิบัติ
#
# เกณฑ์เลือก: Recall สูงที่สุด
# Recall = จับนักศึกษาที่จะจบช้าได้กี่ % (ไม่อยากพลาดใครเลย)
# ============================================================
def compare_three_models(X, y):

    models = {
        "Logistic Regression": Pipeline([
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler",  StandardScaler()),
            ("model",   LogisticRegression(
                class_weight="balanced", max_iter=1000, random_state=42
            )),
        ]),
        "Random Forest": Pipeline([
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler",  StandardScaler()),
            ("model",   RandomForestClassifier(
                n_estimators=200, max_depth=6, min_samples_leaf=3,
                class_weight="balanced", random_state=42, n_jobs=-1,
            )),
        ]),
        "Gradient Boosting": Pipeline([
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler",  StandardScaler()),
            ("model",   GradientBoostingClassifier(
                n_estimators=200, max_depth=4, learning_rate=0.05, random_state=42,
            )),
        ]),
    }

    cv      = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    scoring = ["recall", "roc_auc", "f1", "accuracy"]

    print("\n" + "=" * 66)
    print("  เปรียบเทียบ 3 โมเดล  (5-Fold Cross-Validation)")
    print("  * Recall = จับนักศึกษาเสี่ยงได้กี่ %  (สำคัญที่สุด)")
    print("=" * 66)
    print(f"  {'โมเดล':<24}  {'Recall':>8}  {'AUC':>8}  {'F1':>8}  {'Acc':>8}")
    print(f"  {'-'*24}  {'-'*8}  {'-'*8}  {'-'*8}  {'-'*8}")

    results = {}
    for name, pipe in models.items():
        # ใช้ cross_validate เดียว แทน 4x cross_val_score (เร็วขึ้น 4x)
        cv_res   = cross_validate(pipe, X, y, cv=cv, scoring=scoring)
        recall   = cv_res["test_recall"].mean()
        auc      = cv_res["test_roc_auc"].mean()
        f1       = cv_res["test_f1"].mean()
        accuracy = cv_res["test_accuracy"].mean()
        results[name] = {
            "recall": recall, "auc": auc, "f1": f1, "accuracy": accuracy, "pipe": pipe
        }
        print(f"  {name:<24}  {recall:>8.3f}  {auc:>8.3f}  {f1:>8.3f}  {accuracy:>8.3f}")

    print("=" * 66)

    # เลือกโมเดลที่ Recall สูงสุด
    best_name   = max(results, key=lambda k: results[k]["recall"])
    best_recall = results[best_name]["recall"]
    print(f"\n  ✅ โมเดลที่เลือก: {best_name}")
    print(f"     Recall = {best_recall:.3f}  "
          f"(จับนักศึกษาที่จะจบช้าได้ {best_recall*100:.1f}%)")

    best_pipe = results[best_name]["pipe"]

    # แสดง Confusion Matrix ก่อน (CV predictions)
    # จากนั้นค่อย fit ด้วยข้อมูลทั้งหมด เพื่อให้โมเดล production ใช้ข้อมูล 100%
    y_pred = cross_val_predict(best_pipe, X, y, cv=cv)
    cm     = confusion_matrix(y, y_pred)
    tn, fp, fn, tp = cm.ravel()

    print(f"\n  Confusion Matrix — {best_name}")
    print(f"  ┌──────────────────────┬──────────────┬──────────────┐")
    print(f"  │                      │  ทำนาย: ทัน  │  ทำนาย: ช้า │")
    print(f"  ├──────────────────────┼──────────────┼──────────────┤")
    print(f"  │  จริง: จบทัน  ✅     │  {tn:>10,}  │  {fp:>10,}  │")
    print(f"  │  จริง: จบช้า  ⚠️     │  {fn:>10,}  │  {tp:>10,}  │")
    print(f"  └──────────────────────┴──────────────┴──────────────┘")
    print(f"\n  ❌ พลาดนักศึกษาที่จะจบช้า (False Negative) : {fn:,} คน")
    print(f"  ⚠️  แจ้งเตือนเกิน (False Positive)          : {fp:,} คน")
    print("=" * 66)

    # Fit ด้วยข้อมูลทั้งหมด หลังจากได้ CM แล้ว
    best_pipe.fit(X, y)

    return best_pipe, best_name, results


# ============================================================
# STEP 5 — ทำนายนักศึกษาที่ยังเรียนอยู่
# ============================================================
def predict_active_students(pipeline, active_df, feature_cols):
    X_active = active_df[feature_cols]
    probs    = pipeline.predict_proba(X_active)[:, 1]

    result = active_df[[
        "stu_id", "sta_pres_des", "deg_lev_id",
        "fac_id", "Brn_ID", "stu_adm_year", "max_year_filled",
    ]].copy()

    result["prob_late"]  = np.round(probs, 4)
    result["risk_level"] = pd.cut(
        result["prob_late"],
        bins=[0, 0.3, 0.6, 1.0],
        labels=["Low Risk", "Medium Risk", "High Risk"],
        include_lowest=True,
    )
    return result.sort_values("prob_late", ascending=False).reset_index(drop=True)


# ============================================================
# MAIN — รันทั้งหมด
# ============================================================
def main(data_dir=DATA_DIR):
    print("=" * 66)
    print("  Graduate Late Graduation Prediction  v2")
    print("  จุดทำนาย: หลังสอบ Proposal ผ่าน (m2)")
    print("=" * 66)

    # 1. โหลดข้อมูล
    print("\n[1] โหลดข้อมูล...")
    dfs = load_data(data_dir)

    # 2. สร้าง features
    print("\n[2] สร้าง features...")
    full_df = build_features(
        dfs["student"], dfs["milestone"], dfs["scholar"], dfs["nonstu"]
    )

    # 3. แยกนักศึกษาที่จบแล้ว vs ยังเรียนอยู่
    grad_df   = full_df[full_df["sta_pres_des"] == GRADUATED_STATUS].copy()
    active_df = full_df[full_df["sta_pres_des"].isin(ACTIVE_STATUSES)].copy()

    # 4. กรองเฉพาะคนที่สอบ Proposal ผ่านแล้ว
    print(f"\n[3] กรอง training set เฉพาะผ่าน Proposal...")
    print(f"  นักศึกษาที่จบแล้วทั้งหมด     : {len(grad_df):,} คน")
    grad_df   = grad_df[grad_df["proposal_passed"] == 1].copy()
    print(f"  ผ่าน Proposal แล้ว (training) : {len(grad_df):,} คน")
    active_df = active_df[active_df["proposal_passed"] == 1].copy()
    print(f"  ยังเรียนอยู่ ผ่าน Proposal    : {len(active_df):,} คน")

    # 5. สร้าง label จบทัน/จบช้า
    print("\n[4] สร้าง label จบทัน/จบช้า...")
    grad_df = create_target(grad_df)

    # ลบ feature ที่ไม่มีข้อมูลเลย
    valid_cols = [c for c in FEATURE_COLS if c in grad_df.columns and not grad_df[c].isnull().all()]
    dropped    = set(FEATURE_COLS) - set(valid_cols)
    if dropped:
        print(f"  ตัด feature ที่ไม่มีข้อมูล: {dropped}")

    X = grad_df[valid_cols]
    y = grad_df["late"]

    # 6. เปรียบเทียบ 3 โมเดล
    print("\n[5] เปรียบเทียบ 3 โมเดล...")
    best_model, best_name, all_results = compare_three_models(X, y)

    # 7. ทำนายนักศึกษาที่ยังเรียนอยู่
    if len(active_df) > 0:
        print(f"\n[6] ทำนายนักศึกษาปัจจุบัน {len(active_df):,} คน...")
        predictions = predict_active_students(best_model, active_df, valid_cols)

        out_path = os.path.join(data_dir, "predictions_v2.csv")
        predictions.to_csv(out_path, index=False, encoding="utf-8-sig")

        rc = predictions["risk_level"].value_counts()
        print(f"\n  ┌─────────────────────────────────────┐")
        print(f"  │  ผลการทำนาย ({best_name})")
        print(f"  ├─────────────────────────────────────┤")
        print(f"  │  🔴 High Risk   (เสี่ยงสูง)  : {rc.get('High Risk',   0):>5} คน │")
        print(f"  │  🟡 Medium Risk (เสี่ยงกลาง) : {rc.get('Medium Risk', 0):>5} คน │")
        print(f"  │  🟢 Low Risk    (เสี่ยงต่ำ)  : {rc.get('Low Risk',    0):>5} คน │")
        print(f"  └─────────────────────────────────────┘")
        print(f"\n  บันทึกผลที่: {out_path}")
    else:
        print("\n  ไม่มีนักศึกษาปัจจุบันที่ผ่าน Proposal แล้ว")

    print("\n" + "=" * 66)
    print("  เสร็จสิ้น")
    print("=" * 66)


if __name__ == "__main__":
    main()
