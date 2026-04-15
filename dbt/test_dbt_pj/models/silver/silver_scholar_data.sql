SELECT
    s.stu_ID,
    s.Sch_ID,
    s.Scholar_thai,
    s.Scholar_eng ,
    s.Rec_Syear,
    s.F_Term,
    s.Rec_Eyear,
    s.L_Term,
    s.GetDate,
    s.FinalDate,
    s.Amount
    -- sd.stu_adm_year

FROM
bronze.scholar s

Left join silver_student_data sd
ON  s.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2558;