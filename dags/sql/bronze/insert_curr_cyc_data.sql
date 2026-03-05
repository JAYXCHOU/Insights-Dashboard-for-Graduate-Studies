Insert into bronze.curriculum_cyc(
    cur_id,
    cur_rn,
    study_type,
    [plan],
    mm,
    max_term
)
SELECT 
   scc.cur_id,
   scc.cur_rn,
   scc.study_type,
   scc.[plan],
   scc.mm,
   scc.max_term
From 
dbo.ICT_curri_cycle scc
WHERE NOT EXISTS(
    SELECT 1 FROM 
    bronze.curriculum_cyc cc
    WHERE scc.cur_id = cc.cur_id
)
