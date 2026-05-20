-- TRUNCATE + INSERT ใน Transaction: ล้างแล้ว reload ทั้งหมดทุกรอบ
-- ถ้า INSERT error ระหว่างทาง จะ ROLLBACK กลับสถานะเดิมอัตโนมัติ
BEGIN TRANSACTION;
    TRUNCATE TABLE bronze.grade_stu;

    INSERT INTO bronze.grade_stu(
        Stu_ID, Reg_Year, Reg_Term, Subj_ID, Subj_Rn,
        Credit, Reg_Grad,
        loaded_at
    )
    SELECT
        Stu_ID, Reg_Year, Reg_Term, Subj_ID, Subj_Rn,
        Credit, Reg_Grad,
        GETDATE()
    FROM dbo.ICT_GradeStu;
COMMIT;
