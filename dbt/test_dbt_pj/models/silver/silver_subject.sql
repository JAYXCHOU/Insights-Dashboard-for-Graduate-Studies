SELECT
    subj_id,
    subj_rn,
    NULLIF(LTRIM(RTRIM(subj_nen_f)), '')                AS subj_nen_f,
    subj_id_th,
    NULLIF(LTRIM(RTRIM(subj_nth_f)), '')                AS subj_nth_f,
    subj_credit,
    subj_des_th,
    subj_des_en,
    cur_id,
    cur_rn,
    study_type,
    NULLIF(LTRIM(RTRIM(tsubj_nen)),  '')                AS tsubj_nen
FROM bronze.subject
