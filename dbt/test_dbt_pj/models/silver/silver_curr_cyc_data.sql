SELECT 
    cur_id,
    cur_rn,
    study_type,
    [plan],
    mm,
    max_term
FROM
bronze.curriculum_cyc
WHERE [plan] IN ('ก1', 'ก2', 'ข', '1.1', '1.2', '2.1', '2.2')