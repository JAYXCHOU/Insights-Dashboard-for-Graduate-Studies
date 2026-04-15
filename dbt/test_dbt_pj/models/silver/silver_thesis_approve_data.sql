SELECT
    a.stu_id
    ,a.rn
    ,a.Gr_ID,
    'aprv' as ID_form
    ,a.status_apv AS ID_form_by
    ,a.status_apv_desc

    -- QA: 'Y' มี 2 ความหมายขึ้นกับ status_apv
    --   Y + ACD (งานบริการการศึกษา) = รับทราบ  → เปลี่ยนเป็น 'A'
    --   Y + ADV/CHM                  = เห็นชอบ  → คง 'Y' ไว้
    --   ' ' (space)                  = NULL
    ,CASE
        WHEN QA = 'Y' AND a.status_apv = 'ACD' THEN 'A'

        WHEN NULLIF(LTRIM(RTRIM(QA)), '') IS NULL      THEN NULL
        ELSE QA
    END                                                 AS QA,
    CASE
        WHEN QA = 'Y' AND a.status_apv = 'ACD' THEN N'รับทราบ'
        WHEN NULLIF(LTRIM(RTRIM(QA)), '') IS NULL      THEN NULL
        ELSE QA_desc
    END                                                 AS QA_desc
    ,a.QA_text
    ,a.apv_time,
    CONVERT(VARCHAR(10), CAST(a.apv_time AS DATETIME), 112) AS add_date_key,

    CONVERT(VARCHAR(10), CAST(a.apv_time AS DATETIME), 111) AS add_date

FROM bronze.thesis_approve a

Left join silver_student_data sd
ON  a.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2015;
