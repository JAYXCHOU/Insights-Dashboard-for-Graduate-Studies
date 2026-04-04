WITH union_data AS(
SELECT DISTINCT
    stu_id,
    'pd39' AS event_type,
    Replace(PD_DateNo,'/','') AS date_no, 
    Replace(pd_DatePass,'/','') AS date_pass

From  bronze.thesis
WHERE TRY_CAST(stu_id AS INT) >= 5800000

UNION ALL

SELECT DISTINCT
  stu_id,
  'pt1' AS event_type,
  Replace(pt_dateno,'/','') AS date_no,
  NULL AS date_pass
From  bronze.thesis
WHERE TRY_CAST(stu_id AS INT) >= 5800000

UNION ALL

SELECT DISTINCT
  stu_id,
  'pub2' AS event_type,
  Replace(pub_DateNo,'/','')  AS date_no,
  Replace(pub_DatePass,'/','') AS date_pass
From  bronze.thesis
WHERE TRY_CAST(stu_id AS INT) >= 5800000
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
)

SELECT
    stu_id,
    event_type AS ID_form,

    CASE
        WHEN LEN(start_date_be) = 8
        THEN start_date_be
        ELSE NULL
    END AS start_date,

    CASE
        WHEN LEN(pass_date_be) = 8
        THEN pass_date_be
        ELSE NULL
    END AS pass_date

FROM be_fixed