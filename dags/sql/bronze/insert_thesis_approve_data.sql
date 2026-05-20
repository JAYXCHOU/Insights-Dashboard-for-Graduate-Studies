-- Backfill: อัปเดตแถวเก่าที่ยังไม่มี loaded_at (safe to leave ไว้ตลอด)
UPDATE bronze.thesis_approve
SET loaded_at = '2000-01-01 00:00:00'
WHERE loaded_at IS NULL;

-- Append-only: INSERT ทุกรอบ ไม่มี WHERE NOT EXISTS
-- Silver จะเลือกเฉพาะ snapshot ล่าสุดของแต่ละ stu_id + rn ผ่าน loaded_at DESC
INSERT INTO bronze.thesis_approve(
    stu_id, rn, Gr_ID, status_apv, status_apv_desc,
    QA, QA_desc, QA_text, apv_time,
    loaded_at
)
SELECT
    ta.stu_id, ta.rn, ta.Gr_ID, ta.status_apv, ta.status_apv_desc,
    ta.QA, ta.QA_desc, ta.QA_text, ta.apv_time,
    GETDATE()
FROM dbo.ICT_Thesis_approve ta;
