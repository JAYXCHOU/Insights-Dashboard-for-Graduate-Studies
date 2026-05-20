
-- Backfill: อัปเดตแถวเก่าที่ยังไม่มี loaded_at (safe to leave ไว้ตลอด)
UPDATE bronze.stu_snonstu
SET loaded_at = '2000-01-01 00:00:00'
WHERE loaded_at IS NULL;

INSERT INTO bronze.stu_snonstu(
    stu_id,
    snon_term,
    snon_year,
    snon_memo,
    nstu_id,
    sta_outdate,
    loaded_at
)
SELECT
    stu_ID,
    SNon_Term,
    SNon_Year,
    SNon_Memo,
    RIGHT('00' + CAST(NStu_ID AS varchar), 2),
    Sta_OutDate,
    GETDATE()
FROM dbo.ICT_Stu_SNonStu s

WHERE NOT EXISTS (
    SELECT 1
    FROM bronze.stu_snonstu b
    WHERE s.stu_ID = b.stu_id
    AND s.SNon_Term = b.snon_term
    AND s.SNon_Year = b.snon_year
);