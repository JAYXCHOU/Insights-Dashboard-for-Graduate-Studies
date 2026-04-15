SELECT
    i.inv_id,
    i.reg_year,
    i.reg_term,
    i.inv_date,
    --Replace(inv_date,'/','') AS inv_date_key, 
    --Replace(inv_pay_Date,'/','') AS inv_pay_date_key
    i.inv_pay_Date,
    -- inv_pay_status: ' ' (space) → NULL
    NULLIF(LTRIM(RTRIM(i.inv_pay_status)), '')   AS inv_pay_status,
    i.inv_total,
    i.stu_id,
    i.inv_by,
    i.inv_pay_timeG

FROM bronze.invoice i
Left join silver_student_data sd
ON  i.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2558
