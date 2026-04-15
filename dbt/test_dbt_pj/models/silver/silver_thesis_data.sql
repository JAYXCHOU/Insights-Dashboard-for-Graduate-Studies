SELECT
    t.stu_id,
    t.ID_form,
    t.form_name_th,
    t.form_name_en,
    t.step_id,
    t.step,
    CASE 
    WHEN t.add_date IS NULL 
         OR LTRIM(RTRIM(t.add_date)) = ''
         OR TRY_CAST(t.add_date AS INT) = 0
    THEN NULL
    ELSE  CONVERT(VARCHAR(10),TRY_CONVERT(DATE, t.add_date, 111),112)
    END AS add_date_key,

    CASE WHEN t.add_date IS NULL 
         OR LTRIM(RTRIM(t.add_date)) = ''
         OR TRY_CAST(t.add_date AS INT) = 0
    THEN NULL
    ELSE  CONVERT(VARCHAR(10),TRY_CONVERT(DATE, t.add_date, 111),111)
    END AS add_date,

    CONVERT(VARCHAR(10),TRY_CONVERT(DATE, t.submit_date, 111),112) AS submit_date_key,
    CONVERT(VARCHAR(10), TRY_CONVERT(DATE, t.submit_date, 111),111)AS submit_date,
    t.PD_DateNo,
    t.pd_DatePass,
    t.pt_dateno,
    t.pub_DateNo,
    t.pub_DatePass
FROM
bronze.thesis t

Left join silver_student_data sd
ON  t.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2015;