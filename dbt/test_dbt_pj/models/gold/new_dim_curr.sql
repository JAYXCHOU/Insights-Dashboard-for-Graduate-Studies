SELECT
    ROW_NUMBER() OVER (ORDER BY sn.cur_id, sn.cur_rn, sn.study_plan) AS curriculum_key,
    CONCAT(sn.cur_id, '_', sn.cur_rn, '_', sn.study_plan, '_',sn.study_type) AS curriculum_id,
    sn.cur_id,
    sn.cur_rn,
    sn.study_plan,
    sn.study_type,
    -- sn.Brn_ID,
    -- sn.Sub_Brn_ID,
    sc.mm,
    sc.max_term

FROM {{ref('silver_new_curr')}} sn

LEFT JOIN {{ref('silver_curr_cyc_data')}} sc
ON  sn.cur_id =sc.cur_id
AND sn.cur_rn =sc.cur_rn
AND sn.study_plan = sc.[plan]
And sn.study_type =sc.study_type