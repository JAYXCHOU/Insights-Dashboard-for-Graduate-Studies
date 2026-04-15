SELECT
    i.inv_id,
    CASE WHEN i.Reg_Year IS NULL OR LTRIM(RTRIM(i.Reg_Year)) = '' THEN NULL
    ELSE TRY_CAST(i.Reg_Year as INT) - 543
    END as Reg_Year,
    i.reg_term,
    
    -- Replace(inv_date,'/','') AS inv_date_key, 
    -- Replace(inv_pay_Date,'/','') AS inv_pay_date_key,
    CONVERT(VARCHAR(10),DATEADD(YEAR, -543, TRY_CONVERT(DATE, i.inv_date, 111)),112) as inv_date ,
    CONVERT(VARCHAR(10),DATEADD(YEAR, -543, TRY_CONVERT(DATE, i.inv_pay_Date, 111)),112) as inv_pay_Date,

    -- i.inv_date,
    -- i.inv_pay_Date,

    NULLIF(LTRIM(RTRIM(i.inv_pay_status)), '')   AS inv_pay_status,
    i.inv_total,
    i.stu_id,
    i.inv_by,
    i.inv_pay_timeG

FROM bronze.invoice i
Left join silver_student_data sd
ON  i.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2015