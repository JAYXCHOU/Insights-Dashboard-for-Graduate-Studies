-- WITH union_data AS(
-- SELECT DISTINCT
--     stu_id,
--     'pd39' AS event_type,
--     -- PD_DateNo AS date_no, 
--     -- pd_DatePass  AS date_pass
--     Replace(PD_DateNo,'/','') AS date_no, 
--     Replace(pd_DatePass,'/','') AS date_pass
-- From  bronze.thesis

-- UNION ALL

-- SELECT DISTINCT
--   stu_id,
--   'pt1' AS event_type,
--   NULL AS  date_no,
-- --   pt_dateno AS date_pass
--   Replace(pt_dateno,'/','') AS date_pass
-- From  bronze.thesis

-- UNION ALL

-- SELECT DISTINCT
--   stu_id,
--   'pub2' AS event_type,
-- --    pub_DateNo AS date_no,
-- --    pub_DatePass AS date_pass
--   Replace(pub_DateNo,'/','')  AS date_no,
--   Replace(pub_DatePass,'/','') AS date_pass
-- From  bronze.thesis
-- ),

WITH union_data AS(
SELECT DISTINCT
    stu_id,
    '2' AS event_type,
    -- PD_DateNo AS date_no, 
    -- pd_DatePass  AS date_pass
    Replace(PD_DateNo,'/','') AS date_no, 
    Replace(pd_DatePass,'/','') AS date_pass
From  bronze.thesis

UNION ALL

SELECT DISTINCT
  stu_id,
  '3' AS event_type,
  NULL AS  date_no,
--   pt_dateno AS date_pass
  Replace(pt_dateno,'/','') AS date_pass
From  bronze.thesis

UNION ALL

SELECT DISTINCT
  stu_id,
  '4' AS event_type,
--    pub_DateNo AS date_no,
--    pub_DatePass AS date_pass
  Replace(pub_DateNo,'/','')  AS date_no,
  Replace(pub_DatePass,'/','') AS date_pass
From  bronze.thesis
),


Clean_data AS(
    SELECT 
    stu_id,
    event_type,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(date_no,
        '๐','0'),'๑','1'),'๒','2'),'๓','3'),'๔','4'),
        '๕','5'),'๖','6'),'๗','7'),'๘','8'),'๙','9') AS date_no_th_num_fixed,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(date_pass,
        '๐','0'),'๑','1'),'๒','2'),'๓','3'),'๔','4'),
        '๕','5'),'๖','6'),'๗','7'),'๘','8'),'๙','9') AS date_pass_th_num_fixed
    FROM union_data
),

be_fixed AS (
    SELECT
        stu_id,
        event_type,
        -- Handle missing day: literal '__' placeholder OR '00' value
        CASE
            WHEN date_no_th_num_fixed   LIKE '%[_][_]'   THEN LEFT(date_no_th_num_fixed,   6) + '01'
            WHEN RIGHT(date_no_th_num_fixed,   2) = '00' THEN LEFT(date_no_th_num_fixed,   6) + '01'
            ELSE date_no_th_num_fixed
        END AS start_date_be,
        CASE
            WHEN date_pass_th_num_fixed LIKE '%[_][_]'   THEN LEFT(date_pass_th_num_fixed, 6) + '01'
            WHEN RIGHT(date_pass_th_num_fixed, 2) = '00' THEN LEFT(date_pass_th_num_fixed, 6) + '01'
            ELSE date_pass_th_num_fixed
        END AS pass_date_be
    FROM Clean_data
),

cleaned_date AS (
    SELECT
        stu_id,
        event_type,

        CASE 
            WHEN LEN(start_date_be) = 8
            THEN 
                CAST(CAST(LEFT(start_date_be, 4) AS INT) - 543 AS VARCHAR(4))
                + SUBSTRING(start_date_be, 5, 4)
            ELSE NULL
        END AS start_date_ce,

        CASE 
            WHEN LEN(pass_date_be) = 8
            THEN 
                CAST(CAST(LEFT(pass_date_be, 4) AS INT) - 543 AS VARCHAR(4))
                + SUBSTRING(pass_date_be, 5, 4)
            ELSE NULL
        END AS pass_date_ce

    FROM be_fixed
)

SELECT 
    f.stu_id,
    f.event_type AS ID_form,
    CONVERT(Varchar(10),TRY_CONVERT(date,f.start_date_ce,112),112) AS start_date_key,
    CONVERT(Varchar(10),TRY_CONVERT(date,f.start_date_ce,112),111) AS start_date,

    CONVERT(Varchar(10),TRY_CONVERT(date,f.pass_date_ce,112),112) AS pass_date_key,
    CONVERT(varchar(10),TRY_CONVERT(date,f.pass_date_ce,112),111)  AS pass_date
    
    -- f.start_date_ce AS start_date,
    -- f.pass_date_ce AS pass_date
From cleaned_date f
LEFT JOIN silver_student_data sd
ON  f.stu_id = sd.stu_id
WHERE CAST(sd.stu_adm_year AS INT) >= 2015




