SELECT
    stu_id
    ,rn
    ,Gr_ID,
    'aprv' as ID_form

    ,status_apv AS ID_form_by
    ,status_apv_desc
    
    ,QA As step_id
    ,QA_desc
    ,QA_text
    ,apv_time,
    CONVERT(VARCHAR(8), DATEADD(YEAR, 543, CAST(apv_time AS DATETIME)), 112) AS add_date_key
FROM bronze.thesis_approve
WHERE CAST(stu_id AS INT) >= 5800000;