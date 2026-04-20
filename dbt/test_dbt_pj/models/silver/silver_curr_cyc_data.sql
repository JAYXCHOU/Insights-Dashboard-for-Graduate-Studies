With selected_plan AS(
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

)
Select 
    cur_id,
    cur_rn,
    study_type,
    [plan],
    -- CASE 
    --   WHEN [plan] Is NULL THEN NULL
    --   ELSE Left(TRIM([plan]),1) 
    -- End AS study_plan,
    mm,
    max_term
    
from selected_plan p
