/*
phase 1 : min submit date -> max pass date GR2 
phase 2 : max pass date GR2 ->  first  ethesis submit date
phase 3 : ethesis submit date -> max eapprove date
phase 4 : eapprove pass date -> pass date GR5
*/

-- Phase 1 : submit date 

-- WITH phase_1_1 AS(
--     SELECT
--         stu_id,
--         -- ID_form,
--         '1' As phase,
--         MIN(submit_date_key) AS  date
--     From silver_thesis_data
--     WHERE ID_form ='1'
--     GROUP BY stu_id,ID_form
-- ),

-- phase_1_2 AS(
--     SELECT
--         stu_id,
--         -- id_form,
--         '1' as phase,
--         MAX(pass_date_key) AS date
--     FROM silver_pd_pt_pub_data
--     WHERE ID_form = '4'
--     GROUP BY stu_id,ID_form
-- ),
WITH phase_1 AS(
    SELECT
        t.stu_id,
        '1' As phase,
        MIN(t.submit_date_key) AS  start_date,
        MAX(p.pass_date_key) AS end_date
    From silver_thesis_data t
    LEFT JOIN silver_pd_pt_pub_data p ON
        t.stu_id = p.stu_id
        AND p.ID_form = '4'
    WHERE t.ID_form ='3'
    GROUP BY t.stu_id
),


-- phase 2 

-- phase_2_1 AS(
--     SELECT
--         stu_id,
--         -- id_form,
--         '2' as phase,
--         MAX(pass_date_key) AS date
--     FROM silver_pd_pt_pub_data
--     WHERE ID_form = '4'
--     GROUP BY stu_id,ID_form
-- ),

-- phase_2_2 As(
--     SELECT
--         stu_id,
--         -- id_form,
--         '2' as phase,
--         MIN(add_date_key) as date
--     FROM silver_thesis_submission_data
--     GROUP BY stu_id,ID_form
-- ),
phase_2 AS(

    SELECT
        p.stu_id,
        '2' as phase,
        MAX(p.pass_date_key) AS start_date,
        MIN(s.add_date_key) As end_date
    FROM silver_pd_pt_pub_data p
    LEFT JOIN silver_thesis_submission_data s
        ON p.stu_id = s.stu_id
    WHERE p.ID_form = '4'
    GROUP BY p.stu_id

),

-- phase 3
-- phase_3_1 As(
--     SELECT
--         stu_id,
--         -- id_form,
--         '3' as phase,
--         MIN(add_date_key) as date
--     FROM silver_thesis_submission_data
--     GROUP BY stu_id,ID_form
-- ),

-- phase_3_2 AS(
--     SELECT 
--         stu_id,
--         '3' as phase,
--         Max(add_date_key) as date
--     FROM silver_thesis_approve_data
--     GROUP BY stu_id,ID_form
-- ),

phase_3 AS(
    SELECT
        s.stu_id,
        '3' as phase,
        MIN(s.add_date_key) as start_date,
        Max(a.add_date_key) as end_date
    FROM silver_thesis_submission_data s
    LEFT JOIN silver_thesis_approve_data a 
        On s.stu_id = a.stu_id
    GROUP BY s.stu_id
),
-- phase4

-- phase_4_1 AS(
--     SELECT 
--         stu_id,
--         '4' as phase,
--         Max(add_date_key) as date
--     FROM silver_thesis_approve_data
--     GROUP BY stu_id,ID_form
-- ),

-- phase_4_2 AS(
--     SELECT
--         stu_id,
--         -- id_form,
--         '4' as phase,
--         Max(submit_date_key) as date
--     FROM silver_thesis_data
--     WHERE id_form ='22'
--     GROUP BY stu_id,id_form
-- ),
phase_4 As(
    SELECT 
        a.stu_id,
        '4' as phase,
        Max(a.add_date_key) as start_date,
        MAX(t.submit_date_key) as end_date
    FROM silver_thesis_approve_data a
    LEFT JOIN silver_thesis_data t 
        On a.stu_id =t.stu_id 
        AND t.id_form = '22'
    GROUP BY a.stu_id
),

union_all_phase AS(
    Select * from  phase_1
    UNION ALL
    Select * from phase_2
    UNION ALL
    SELECT * from phase_3
    UNION ALL
    Select * from  phase_4
),

-- union_all_phase AS(
--     Select * from  phase_1_1
--     UNION ALL
--     Select * from phase_1_2
--     UNION ALL
--     SELECT * from phase_2_1
--     UNION ALL
--     Select * from  phase_2_2
--     UNION ALL
--     Select * from phase_3_1
--     UNION ALL
--     SELECT * from phase_3_2
--     UNION ALL
--     Select * from phase_4_1
--     UNION ALL
--     SELECT * from phase_4_2
-- ), 

join_dim_period As(
    SELECT 
        u.stu_id,
        p.period_id as period_id,
        p.period_name,
        u.start_date,
        u.end_date
    FROM union_all_phase u
    LEFT JOIN dim_period p ON
        u.phase = p.period_id
),

join_dim_student AS (
    SELECT
        ds.stu_id,
        ds.cur_id,
        ds.cur_rn,
        ds.study_type,
        ds.stu_prg_plan,

        p.period_id, 
        p.period_name,
        p.start_date,
        p.end_date
    FROM join_dim_period p
    Left JOIN {{ref('dim_student')}} ds
        on  p.stu_id = ds.stu_id 
),

final AS(
    SELECT
        s.stu_id,
        dc.curriculum_key,
        s.period_id, 
        s.period_name,

        dd.date_display As start_date,
        dd2.date_display AS end_date
        -- s.start_date,
        -- s.end_date

    FROM join_dim_student s
    Left JOIN {{ref('dim_curriculum')}} dc
        ON s.cur_id = dc.cur_id
        AND s.cur_rn = dc.cur_rn
        AND s.stu_prg_plan = dc.study_plan
        AND s.study_type = dc.study_type

    LEFT JOIN {{ref('dim_date')}} dd    
        ON s.start_date = dd.date_key

    LEFT JOIN {{ref('dim_date')}} dd2
        ON s.end_date = dd2.date_key
)

Select * FROM final

-- agg AS (

--     SELECT 
--         stu_id,
--         period_id,
--         Min(date) as start_date,
--         Max(date) as end_date
--     from join_dim_period
--     Group BY stu_id,period_id
-- )

-- Select * from agg
