-- Backfill: อัปเดตแถวเก่าที่ยังไม่มี loaded_at (safe to leave ไว้ตลอด)
UPDATE bronze.subject
SET loaded_at = '2000-01-01 00:00:00'
WHERE loaded_at IS NULL;

INSERT INTO bronze.subject(
    subj_id   ,
    subj_rn   ,
    subj_nen_f,
    subj_id_th,
    subj_nth_f,
    subj_credit,
    subj_des_th,
    subj_des_en,
    cur_id    ,
    cur_rn    ,
    study_type,
    tsubj_nen,
    loaded_at
)
SELECT
    subj_id   ,
    subj_rn   ,
    subj_nen_f,
    subj_id_th,
    subj_nth_f,
    subj_credit,
    subj_des_th,
    subj_des_en,
    cur_id    ,
    cur_rn    ,
    study_type,
    tsubj_nen,
    GETDATE()
FROM
dbo.ICT_Subject sj

WHERE NOT EXISTS(
    SELECT 1
    FROM bronze.subject bs
    WHERE sj.subj_id = bs.subj_id
    AND   sj.subj_rn = bs.subj_rn
    AND   sj.cur_id  = bs.cur_id
    AND   sj.cur_rn  = bs.cur_rn
);
