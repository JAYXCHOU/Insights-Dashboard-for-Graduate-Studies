-- Backfill: อัปเดตแถวเก่าที่ยังไม่มี loaded_at (safe to leave ไว้ตลอด)
UPDATE bronze.curriculum_cyc
SET loaded_at = '2000-01-01 00:00:00'
WHERE loaded_at IS NULL;

INSERT INTO bronze.curriculum_cyc(
    cur_id, cur_rn, study_type, [plan], mm, max_term,
    loaded_at
)
SELECT
    scc.cur_id, scc.cur_rn, scc.study_type, scc.[plan], scc.mm, scc.max_term,
    GETDATE()
FROM dbo.ICT_curri_cycle scc
WHERE NOT EXISTS(
    SELECT 1 FROM bronze.curriculum_cyc cc
    WHERE scc.cur_id = cc.cur_id
      AND scc.cur_rn = cc.cur_rn  -- แก้ bug: เพิ่ม cur_rn ใน key
);
