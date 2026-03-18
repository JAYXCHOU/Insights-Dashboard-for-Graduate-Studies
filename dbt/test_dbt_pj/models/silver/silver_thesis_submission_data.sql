SELECT
    sub_stu AS stu_id,
    'sub' as ID_form,
    'sub' as step_id,
    save_time,
    CONVERT(VARCHAR(8), DATEADD(YEAR, 543, CAST(save_time AS DATETIME)), 112) AS add_date_key
FROM
    bronze.thesis_submission
WHERE CAST(sub_stu AS INT) >= 5800000;