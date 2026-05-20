-- Backfill: อัปเดตแถวเก่าที่ยังไม่มี loaded_at (safe to leave ไว้ตลอด)
UPDATE bronze.thesis
SET loaded_at = '2000-01-01 00:00:00'
WHERE loaded_at IS NULL;

-- Append-only: INSERT ทุกรอบ ไม่มี WHERE NOT EXISTS
-- Silver จะเลือกเฉพาะ snapshot ล่าสุดของแต่ละ stu_id + ID_form ผ่าน loaded_at DESC
INSERT INTO bronze.thesis(
    stu_id, ID_form, form_name_th, form_name_en, step_id, step,
    add_date, submit_date, PD_DateNo, pd_DatePass, pt_dateno,
    pub_DateNo, pub_DatePass,
    loaded_at
)
SELECT
    d.stu_id, d.ID_form, d.form_name_th, d.form_name_en, d.step_id, d.step,
    d.add_date, d.submit_date, d.PD_DateNo, d.pd_DatePass, d.pt_dateno,
    d.pub_DateNo, d.pub_DatePass,
    GETDATE()
FROM dbo.ICT_Thesis_Data d;
