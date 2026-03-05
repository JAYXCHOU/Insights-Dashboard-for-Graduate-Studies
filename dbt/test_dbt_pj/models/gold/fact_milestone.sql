-- SELECT
--     s.stu_id,
--     s.cur_id,
--     dm.ID_form,
--     std.step_id,
--     std.step,
--     dd.date_key

-- FROM {{ref('silver_thesis_data')}} std

-- LEFT JOIN {{ ref('dim_milestone')}} dm
--  ON std.ID_form = dm.ID_form

-- LEFT JOIN {{ ref('dim_student')}} s
--  ON std.stu_id = s.stu_ID

-- -- LEFT JOIN {{ref('dim_curriculum')}} c
-- --     ON std.
-- LEFT JOIN {{ref('dim_date')}} dd
--  ON std.add_date_key = dd.date_key

WITH thesis_data AS(
    SELECT
    std.stu_id,
    std.step_id,
    dm.ID_form,
    std.add_date_key,
    std.submit_date_key
    FROM {{ref('silver_thesis_data')}} std
    LEFT JOIN {{ref ('dim_milestone')}} dm
        on std.ID_form = dm.ID_form
),

joined_with_student AS (
    SELECT 
        ds.stu_id,
        ds.cur_id,
        ds.cur_rn,
        ds.Brn_ID,
        ds.stu_prg_plan,
        ds.stu_app_plan,
        td.step_id,
        td.ID_form,
        td.add_date_key,
        td.submit_date_key
    FROM thesis_data td
    Left JOIN {{ref('dim_student')}} ds
        on  td.stu_id = ds.stu_id
),

fact_miles AS(
    SELECT

        jws.stu_id,
        dc.curriculum_id,
        dc.cur_id,
        dc.cur_rn,
        dc.Brn_ID,
        jws.stu_prg_plan,
        jws.stu_app_plan,
        jws.step_id,
        jws.ID_form,
        dd.date_key As add_date,
        dd2.date_key AS submit_date

    FROM joined_with_student jws

    Left JOIN {{ref('dim_curriculum')}} dc
        ON jws.cur_id = dc.cur_id
        AND jws.cur_rn = dc.cur_rn
        AND jws.Brn_ID = dc.Brn_ID
        AND jws.stu_prg_plan = dc.study_plan

    LEFT JOIN {{ref('dim_date')}} dd    
        ON jws.add_date_key = dd.date_key

    LEFT JOIN {{ref('dim_date')}} dd2
        ON jws.submit_date_key = dd2.date_key
)

SELECT * From fact_miles;


