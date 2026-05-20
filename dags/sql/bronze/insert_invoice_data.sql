-- TRUNCATE + INSERT ใน Transaction: ล้างแล้ว reload ทั้งหมดทุกรอบ
BEGIN TRANSACTION;
    TRUNCATE TABLE bronze.invoice;

    INSERT INTO bronze.invoice(
        inv_id, reg_year, reg_term, inv_date, inv_pay_Date,
        inv_pay_status, inv_total, stu_id, inv_by,
        inv_pay_timeG, GRID,
        loaded_at
    )
    SELECT
        inv_id, reg_year, reg_term, inv_date, inv_pay_Date,
        inv_pay_status, inv_total, stu_id, inv_by,
        inv_pay_timeG, GRID,
        GETDATE()
    FROM dbo.ICT_invoice;
COMMIT;
