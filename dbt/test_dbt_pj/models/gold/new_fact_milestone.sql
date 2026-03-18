
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

Union_pt_pd_pub AS(
    SELECT 
    stu_id, 
    ID_form,
    '0' as step_id, 
    CAST(start_date AS int) AS add_date_key, 
    CAST(pass_date AS int) AS submit_date_key
    FROM {{ref('silver_pd_pt_pub_data')}} spd

    UNION ALL

    SELECT 
        td.stu_id,
        CAST(td.ID_form AS VARCHAR(10)) as ID_form,
        CAST(td.step_id AS VARCHAR(10)) as step_id,
        td.add_date_key,
        td.submit_date_key
    FROM thesis_data td
),

joined_with_student AS (
    SELECT 
        ds.stu_id,
        ds.cur_id,
        ds.cur_rn,
        ds.Brn_ID,
        ds.Sub_Brn_ID,
        ds.study_type,
        ds.stu_prg_plan,
        ds.stu_app_plan,
        td.step_id,
        td.ID_form,
        td.add_date_key,
        td.submit_date_key
    FROM Union_pt_pd_pub td
    Left JOIN {{ref('dim_student')}} ds
        on  td.stu_id = ds.stu_id
),

fact_miles AS(
    SELECT
        jws.stu_id,
        dc.curriculum_key,
 
        jws.step_id,
        jws.ID_form,

        dd.date_key As add_date,
        dd2.date_key AS submit_date

    FROM joined_with_student jws

    Left JOIN {{ref('dim_curriculum')}} dc
        ON jws.cur_id = dc.cur_id
        AND jws.cur_rn = dc.cur_rn
        AND jws.stu_prg_plan = dc.study_plan
        AND jws.study_type = dc.study_type

    LEFT JOIN {{ref('dim_date')}} dd    
        ON jws.add_date_key = dd.date_key

    LEFT JOIN {{ref('dim_date')}} dd2
        ON jws.submit_date_key = dd2.date_key
)

SELECT * From fact_miles WHERE stu_id is NOT NULL;


