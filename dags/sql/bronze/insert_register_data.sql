-- TRUNCATE + INSERT ใน Transaction: ล้างแล้ว reload ทั้งหมดทุกรอบ
BEGIN TRANSACTION;
    TRUNCATE TABLE bronze.register;

    INSERT INTO bronze.register(
        Stu_ID, Reg_Year, Reg_Term, Subj_ID, Subj_Rn,
        Reg_Credit, subj_nen, subj_nth, subj_id_th,
        loaded_at
    )
    SELECT
        Stu_ID, Reg_Year, Reg_Term, Subj_ID, Subj_Rn,
        Reg_Credit, subj_nen, subj_nth, subj_id_th,
        GETDATE()
    FROM dbo.ICT_Register;
COMMIT;
