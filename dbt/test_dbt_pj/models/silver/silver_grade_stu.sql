SELECT
    Stu_ID                                              AS stu_id,
    Reg_Year,
    Reg_Term,
    Subj_ID,
    Subj_Rn,
    Credit,
    -- TRIM trailing/leading spaces ออกจากเกรด
    -- NULL และ empty string → NULL
    NULLIF(LTRIM(RTRIM(Reg_Grad)), '')                  AS Reg_Grad
FROM bronze.grade_stu
WHERE TRY_CAST(Stu_ID AS INT) >= 5800000
