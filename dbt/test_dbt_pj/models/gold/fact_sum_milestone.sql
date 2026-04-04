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
        pass_date AS event_date,
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
        dm.ID_form_name as ID_form,
        a.event_date,
        a. event_type
    from all_events  a
    LEFT JOIN dim_milestone dm ON
        a.ID_form = dm.ID_form
),

agg As(
    SELECT
        stu_id,
        id_form,
        MIN(event_date) AS submit_date,
        max(event_date) AS pass_date,
        Count(CASE WHEN event_date IS NOT NULL THEN 1 END) as count_action
    FROM join_milestone
    GROUP BY stu_id, ID_form
),

stu AS (
    SELECT DISTINCT 
    stu_id 
    FROM agg
),

milestone AS (
    SELECT DISTINCT 
     ID_form_name as id_form
    FROM dim_milestone
),

cross_join AS (
    SELECT 
        s.stu_id,
        m.id_form
    FROM stu s
    CROSS JOIN milestone m
)
Select 
    c.stu_id,
    c.id_form,
    a.submit_date,
    a.pass_date,
    a.count_action
from cross_join c 
LEFT JOIN agg a
    ON a.stu_id = c.stu_id
    And a.id_form = c.id_form
