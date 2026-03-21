INSERT INTO bronze.invoice(
    inv_id        ,
    reg_year      ,
    reg_term      ,
    inv_date      ,
    inv_pay_Date  ,
    inv_pay_status,
    inv_total     ,
    stu_id        ,
    inv_by        ,
    inv_pay_timeG ,
    GRID
)
SELECT
    inv_id        ,
    reg_year      ,
    reg_term      ,
    inv_date      ,
    inv_pay_Date  ,
    inv_pay_status,
    inv_total     ,
    stu_id        ,
    inv_by        ,
    inv_pay_timeG ,
    GRID
FROM
dbo.ICT_invoice iv

WHERE NOT EXISTS(
    SELECT 1
    FROM bronze.invoice bi
    WHERE iv.inv_id = bi.inv_id
);
