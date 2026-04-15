SELECT
    sd.Stu_ID  AS stu_id,
    
    CASE WHEN g.Reg_Year IS NULL OR LTRIM(RTRIM(g.Reg_Year)) = '' THEN NULL
    ELSE TRY_CAST(g.Reg_Year as INT) - 543
    END as Reg_Year ,

    g.Reg_Term,

    g.Subj_ID,
    g.Subj_Rn,
    g.Credit,
    -- TRIM trailing/leading spaces ออกจากเกรด
    -- NULL และ empty string → NULL
    NULLIF(LTRIM(RTRIM(g.Reg_Grad)), '')   AS Reg_Grad

FROM bronze.grade_stu g
Left join silver_student_data sd
ON  g.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2015