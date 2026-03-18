WITH union_data AS(
SELECT DISTINCT
    stu_id,
    'pd39' AS event_type,
    -- PD_DateNo AS date_no,
    Replace(PD_DateNo,'/','') AS date_no, 
    -- pd_DatePass AS date_pass
    Replace(pd_DatePass,'/','') AS date_pass

From  bronze.thesis
WHERE CAST(stu_id AS INT) >= 5800000
UNION ALL

SELECT DISTINCT
  stu_id,
  'pt1' AS event_type,
--   pt_dateno AS date_no,
  Replace(pt_dateno,'/','') AS date_no,
  NULL AS date_pass
From  bronze.thesis
WHERE CAST(stu_id AS INT) >= 5800000
UNION ALL

SELECT DISTINCT
  stu_id,
  'pub2' AS event_type,
--   pub_DateNo AS date_no,
  Replace(pub_DateNo,'/','')  AS date_no,
--   pub_DatePass AS date_pass
    Replace(pub_DatePass,'/','') AS date_pass
From  bronze.thesis
WHERE CAST(stu_id AS INT) >= 5800000
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
)

SELECT
    stu_id,
    event_type as ID_form,
    CASE 
        WHEN date_no_th_num_fixed Like '%__' THEN  Replace(date_no_th_num_fixed,'__','01') 
        -- Else Replace(date_no_th_num_fixed,'/','') 
        Else date_no_th_num_fixed End As start_date,
    CASE 
        WHEN date_pass_th_num_fixed Like '%__' THEN  Replace(date_pass_th_num_fixed,'__','01') 
        ELSE date_pass_th_num_fixed End As pass_date
        -- Else   Replace(date_pass_th_num_fixed,'/','') End As pass_date
    -- date_pass_th_num_fixed as pass_date
FROM Clean_data