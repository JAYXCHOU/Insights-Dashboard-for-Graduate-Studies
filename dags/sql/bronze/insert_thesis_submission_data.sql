-- Backfill: อัปเดตแถวเก่าที่ยังไม่มี loaded_at (safe to leave ไว้ตลอด)
UPDATE bronze.thesis_submission
SET loaded_at = '2000-01-01 00:00:00'
WHERE loaded_at IS NULL;

Insert into bronze.thesis_submission(
    sub_stu,
    save_time,
    loaded_at
)
SELECT
    ts.sub_stu,
    ts.save_time,
    GETDATE()
From
dbo.ICT_Thesis_submission ts
WHERE NOT EXISTS (
    SELECT 1
    FROM bronze.thesis_submission bs
    WHERE 
        ts.sub_stu = bs.sub_stu
        AND ts.save_time = bs.save_time
);