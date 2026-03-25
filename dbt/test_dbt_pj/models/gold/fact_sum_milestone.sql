-- WITH all_events AS (

--     SELECT 
--         std.stu_id,
--         dm.ID_form_name AS ID_form,
--         std.submit_date_key AS submit_date,
--         NULL AS pass_date
--     FROM silver_thesis_data std
--     LEFT JOIN dim_milestone dm 
--         ON CAST(std.ID_form AS varchar(20)) = dm.ID_form 

--     UNION ALL

--     SELECT 
--         p.stu_id,
--         dm.ID_form_name AS ID_form,
--         NULL AS submit_date,
--         p.pass_date
--     FROM silver_pd_pt_pub_data p
--     LEFT JOIN dim_milestone dm 
--         ON CAST(p.ID_form AS varchar(20)) = dm.ID_form
-- )

-- SELECT 
--     stu_id,
--     ID_form,
--     MIN(submit_date) AS submit_date,
--     MAX(pass_date) AS pass_date,
--     COUNT(*) AS count_action,
--     COUNT(ID_form) AS count_ID_form
-- FROM all_events
-- GROUP BY stu_id,ID_form

    SELECT 
	    std.stu_id As stu_id,
	    dm.ID_form_name  as ID_form,
        MIN(std.submit_date_key) AS submit_date,
        MAX(p.pass_date) AS pass_date,
        COUNT(ID_form_name) AS count_id_form

    FROM silver_thesis_data std

    LEFT JOIN dim_milestone dm 
        ON CAST(std.ID_form AS varchar(20))  = dm.ID_form 
    LEFT JOIN silver_pd_pt_pub_data p 
        ON std.stu_id = p.stu_id

    GROUP BY std.stu_id,dm.ID_form_name 

-- SELECT 
--     std.stu_id,
--     dm.ID_form_name AS ID_form,
--     COUNT(*) AS count_action
-- FROM silver_thesis_data std

-- LEFT JOIN dim_milestone dm 
--     ON CAST(std.ID_form AS varchar(20)) = dm.ID_form 

-- GROUP BY 
--     std.stu_id,
--     dm.ID_form_name

