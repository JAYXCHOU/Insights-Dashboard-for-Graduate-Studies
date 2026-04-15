SELECT
    t.stu_id,
    t.ID_form,
    t.form_name_th,
    t.form_name_en,
    t.step_id,
    t.step,

    -- TRY_CONVERT(DATE, add_date, 111) AS add_date,
    -- CAST(
    --     CONVERT(VARCHAR(8), 
    --         TRY_CONVERT(DATE, add_date, 111),112)
    -- AS INT) AS add_date_key,
    CAST(
        CONVERT(VARCHAR(8), 
            DATEADD(YEAR, 543, 
                TRY_CONVERT(DATE, t.add_date, 111)
            )
        ,112)
    AS INT) AS add_date_key,
    -- TRY_CONVERT(DATE, submit_date, 111) AS submit_date,
    -- CAST(
    --     CONVERT(VARCHAR(8), 
    --         TRY_CONVERT(DATE, submit_date, 111),112)
    -- AS INT) AS submit_date_key,

     CAST(
        CONVERT(VARCHAR(8), 
            DATEADD(YEAR, 543, 
                TRY_CONVERT(DATE, t.submit_date, 111)
            )
        ,112)
    AS INT) AS submit_date_key,

    t.PD_DateNo,
    t.pd_DatePass ,
    t.pt_dateno,
    t.pub_DateNo,
    t.pub_DatePass
FROM
bronze.thesis t

Left join silver_student_data sd
ON  t.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2558;