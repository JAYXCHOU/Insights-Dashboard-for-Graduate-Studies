WITH event_thesis AS (
    SELECT 
        stu_id,
        CAST(ID_form AS varchar(10)) AS ID_form,
        submit_date_key AS event_date,
        'center' AS event_type
    FROM silver_thesis_data
),

event_pass AS (
    SELECT 
        stu_id,
        CAST(ID_form AS varchar(10)) AS ID_form,
        pass_date_key AS event_date,
        'pd_pt_pub' AS event_type
    FROM silver_pd_pt_pub_data
),

event_submission AS (
    SELECT 
        stu_id,
        CAST(ID_form AS varchar(10)) AS ID_form,
        add_date_key AS event_date,
        'submit' AS event_type
    FROM silver_thesis_submission_data
),

event_apv AS (
    SELECT
        stu_id,
        CAST(ID_form AS varchar(10))AS ID_form,
        add_date_key AS event_date,
        'aprove' AS event_type
    FROM silver_thesis_approve_data
),

all_events AS (
    SELECT * FROM event_thesis
    UNION ALL
    SELECT * FROM event_pass
    UNION ALL
    SELECT * FROM event_submission
    UNION ALL
    SELECT * FROM event_apv
),

join_milestone AS (
    SELECT 
        a.stu_id,
        dm.ID_form,
        dm.ID_form_name as ID_form_name,
       
        a.event_date,
        a.event_type

    from all_events  a
    LEFT JOIN dim_milestone dm ON
        a.ID_form = dm.ID_form
),

agg As(
    SELECT
        stu_id,
        ID_form,
        ID_form_name,
        MIN(event_date) AS submit_date,
        max(event_date) AS pass_date,
        -- Count(CASE WHEN event_date IS NOT NULL THEN 1 END) as count_action
        COUNT(event_type) as count_action
    FROM join_milestone
    GROUP BY stu_id, ID_form, ID_form_name
),
stu AS (
    SELECT DISTINCT 
    stu_id 
    FROM agg
),

milestone AS (
    SELECT DISTINCT 
    ID_form,
    ID_form_name as id_form_name
    FROM dim_milestone
),

cross_join AS (
    SELECT 
        s.stu_id,
        m.ID_form,
        m.id_form_name
    FROM stu s
    CROSS JOIN milestone m
),


final As(
    Select 
    c.stu_id,
    c.ID_form,
    c.id_form_name,
    a.submit_date,
    a.pass_date,
    a.count_action
from cross_join c 
LEFT JOIN agg a
    ON a.stu_id = c.stu_id
    And a.id_form = c.id_form

),

joined_with_student AS(
    SELECT
        ds.stu_id,
        ds.cur_id,
        ds.cur_rn,
        ds.study_type,
        ds.stu_prg_plan,

        f.ID_form,
        f.id_form_name,
        f.submit_date,
        f.pass_date,
        f.count_action

    from final f
    Left JOIN {{ref('dim_student')}} ds
        on  f.stu_id = ds.stu_id
),

fact_sum_mile AS(
    SELECT
        jws.stu_id,
        dc.curriculum_key,
        jws.ID_form,
        jws.id_form_name,
        dd.date_display As submit_date,
        dd2.date_display AS pass_date,
        jws.count_action

    from joined_with_student jws
    Left JOIN {{ref('dim_curriculum')}} dc
        ON jws.cur_id = dc.cur_id
        AND jws.cur_rn = dc.cur_rn
        AND jws.stu_prg_plan = dc.study_plan
        AND jws.study_type = dc.study_type

    LEFT JOIN {{ref('dim_date')}} dd    
        ON jws.submit_date = dd.date_key

    LEFT JOIN {{ref('dim_date')}} dd2
        ON jws.pass_date = dd2.date_key
)

SELECT 
    stu_id,
    curriculum_key,
    ID_form,
    id_form_name,
    submit_date,
    pass_date,
    count_action
from fact_sum_mile 
WHERE stu_id is NOT NULL;