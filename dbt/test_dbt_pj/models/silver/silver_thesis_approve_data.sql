SELECT
    stu_id
    ,rn
    ,Gr_ID
    ,status_apv AS ID_form
    ,status_apv_desc
    -- QA: 'Y' มี 2 ความหมายขึ้นกับ status_apv
    --   Y + ACD (งานบริการการศึกษา) = รับทราบ  → เปลี่ยนเป็น 'A'
    --   Y + ADV/CHM                  = เห็นชอบ  → คง 'Y' ไว้
    --   ' ' (space)                  = NULL
    ,CASE
        WHEN QA = 'Y' AND status_apv = 'ACD' THEN 'A'
        WHEN NULLIF(LTRIM(RTRIM(QA)), '') IS NULL      THEN NULL
        ELSE QA
    END                                                 AS QA,
    CASE
        WHEN QA = 'Y' AND status_apv = 'ACD' THEN N'รับทราบ'
        WHEN NULLIF(LTRIM(RTRIM(QA)), '') IS NULL      THEN NULL
        ELSE QA_desc
    END                                                 AS QA_desc
    ,QA_text
    ,apv_time,
    CONVERT(VARCHAR(8), DATEADD(YEAR, 543, CAST(apv_time AS DATETIME)), 112) AS add_date_key
FROM bronze.thesis_approve
WHERE CAST(stu_id AS INT) >= 5800000;