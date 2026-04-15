SELECT
    r.Stu_ID                                              AS stu_id,
    r.Reg_Year,
    r.Reg_Term,
    r.Subj_ID,
    r.Subj_Rn,
    r.Reg_Credit,
    NULLIF(LTRIM(RTRIM(r.subj_nen)),  '')                 AS subj_nen,
    NULLIF(LTRIM(RTRIM(r.subj_nth)),  '')                 AS subj_nth,
    r.subj_id_th
FROM bronze.register r
LEFT JOIN silver_student_data sd
ON  r.stu_id = sd.stu_id
WHERE CAST(sd.stu_adm_year AS INT) >= 2558