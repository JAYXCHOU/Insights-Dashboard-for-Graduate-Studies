-- SELECT
--     cur_id,
--     cur_rn,
--     study_type,
--     deg_lev_id,
--     cur_name_th,
--     cur_name_en,
--     deg_level,
--     fac_id,
--     fac_name_th,
--     fac_name_en,
--     Brn_ID,
--     Sub_Brn_ID,
--     major_name_th,
--     major_name_en,
--     groupN_id,
--     study_group_type,
--     lang
-- FROM {{ref('silver_curr_data')}}

/* version 2
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY sd.cur_id, sd.cur_rn, sd.study_plan) AS curriculum_key,
    CONCAT(sd.cur_id, '_', sd.cur_rn, '_', sd.study_plan,'_', sd.study_type) AS curriculum_id,
    sd.cur_id,
    sd.cur_rn,
    sd.study_plan,
    sd.study_type,
    sd.cur_name_th,
    sd.cur_name_en,
    sd.deg_lev_id,
    sd.deg_level,
    sd.fac_id,
    sd.fac_name_th,
    sd.fac_name_en,
    --sd.Brn_ID,
    --sd.Sub_Brn_ID,
    --sd.major_name_th,
    --sd.major_name_en,
    sd.groupN_id,
    sd.study_group_type,
    sd.lang,
    sc.mm,
    sc.max_term
FROM silver_curr_data sd

LEFT JOIN {{ref('silver_curr_cyc_data')}} sc
ON  sd.cur_id =sc.cur_id
AND sd.cur_rn =sc.cur_rn
AND sd.study_plan = sc.[plan]
And sd.study_type =sc.study_type
*/

WITH curr_base AS (
    SELECT DISTINCT
        sd.cur_id,
        sd.cur_rn,
        sd.study_plan,
        sd.study_type,
        sd.cur_name_th,
        sd.cur_name_en,
        sd.deg_lev_id,
        sd.deg_level,
        sd.fac_id,
        sd.fac_name_th,
        sd.fac_name_en,
        sd.groupN_id,
        sd.study_group_type,
        sd.lang,
        sc.mm,
        sc.max_term
    FROM silver_curr_data sd
    LEFT JOIN {{ref('silver_curr_cyc_data')}} sc
        ON sd.cur_id = sc.cur_id
        AND sd.cur_rn = sc.cur_rn
        AND sd.study_plan = sc.[plan]
        AND sd.study_type = sc.study_type
)

SELECT
    ROW_NUMBER() OVER (ORDER BY cur_id, cur_rn, study_plan) AS curriculum_key,
    CONCAT(cur_id, '_', cur_rn, '_', study_plan, '_', study_type) AS curriculum_id,
    *
FROM curr_base