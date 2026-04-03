SELECT
    Stu_ID                                              AS stu_id,
    Reg_Year,
    Reg_Term,
    Subj_ID,
    Subj_Rn,
    Reg_Credit,
    NULLIF(LTRIM(RTRIM(subj_nen)),  '')                 AS subj_nen,
    NULLIF(LTRIM(RTRIM(subj_nth)),  '')                 AS subj_nth,
    subj_id_th
FROM bronze.register
WHERE TRY_CAST(Stu_ID AS INT) >= 5800000
