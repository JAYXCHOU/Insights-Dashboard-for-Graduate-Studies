
-- Backfill: อัปเดตแถวเก่าที่ยังไม่มี loaded_at (safe to leave ไว้ตลอด)
UPDATE bronze.sta_nonstu
SET loaded_at = '2000-01-01 00:00:00'
WHERE loaded_at IS NULL;

INSERT INTO bronze.sta_nonstu(
    nstu_id,
    nstu_des_thai,
    nstu_des_eng,
    loaded_at
)
SELECT
    RIGHT('00' + CAST(nstu_id AS varchar), 2),
    nstu_des,
    nstu_desEn,
    GETDATE()
FROM dbo.ICT_sta_nonstu s

WHERE NOT EXISTS (
    SELECT 1
    FROM bronze.sta_nonstu b
    WHERE b.nstu_id = RIGHT('00' + CAST(s.nstu_id AS varchar), 2)
);
