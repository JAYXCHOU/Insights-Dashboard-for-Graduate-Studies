SELECT
    inv_id,
    reg_year,
    reg_term,
    inv_date,
    --Replace(inv_date,'/','') AS inv_date_key, 
    --Replace(inv_pay_Date,'/','') AS inv_pay_date_key
    inv_pay_Date,
    -- inv_pay_status: ' ' (space) → NULL
    NULLIF(LTRIM(RTRIM(inv_pay_status)), '')   AS inv_pay_status,
    inv_total,
    stu_id,
    inv_by,
    inv_pay_timeG

FROM bronze.invoice
WHERE TRY_CAST(stu_id AS INT) >= 5800000