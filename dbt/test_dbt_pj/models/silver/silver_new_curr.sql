SELECT DISTINCT
    cur_id,
    cur_rn,
    study_plan,
    study_type,
    Brn_ID,
    Sub_Brn_ID
FROM {{ref('silver_curr_data')}}

UNION

SELECT DISTINCT
    cur_id,
    cur_rn,
    stu_prg_plan As study_plan,
    study_type,
    Brn_ID,
    Sub_Brn_ID
FROM {{ref('silver_student_data')}}