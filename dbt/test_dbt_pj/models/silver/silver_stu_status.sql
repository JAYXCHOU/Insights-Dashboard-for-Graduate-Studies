WITH joined_data AS (
    SELECT
        s.stu_id,
        s.snon_term,
        s.snon_year,
        s.snon_memo,
        s.nstu_id,
        d.nstu_des_thai,
        d.nstu_des_eng,
        s.sta_outdate,
        ROW_NUMBER() OVER (
            PARTITION BY s.stu_id, s.snon_term, s.snon_year, s.nstu_id 
            ORDER BY s.sta_outdate DESC
        ) AS rn
    FROM bronze.stu_snonstu s
    LEFT JOIN bronze.sta_nonstu d
        ON s.nstu_id = d.nstu_id
),

clean_data AS (
    SELECT
        stu_id,
        TRY_CAST(snon_term AS INT) AS snon_term,  -- ไม่ใช่เลข → NULL
        TRY_CAST(snon_year AS INT) AS snon_year,  -- ไม่ใช่เลข → NULL
        snon_memo,
        nstu_id,
        nstu_des_thai,
        nstu_des_eng,
        REPLACE(sta_outdate, '/', '') AS sta_outdate_clean
    FROM joined_data
    WHERE rn = 1
),

final_data AS (
    SELECT
        stu_id,
        snon_term,
        snon_year,
        snon_memo,
        nstu_id,

        CASE 
            WHEN CHARINDEX(' - ', nstu_des_thai) > 0
            THEN LTRIM(RTRIM(LEFT(nstu_des_thai, CHARINDEX(' - ', nstu_des_thai) - 1)))
            ELSE LTRIM(RTRIM(nstu_des_thai))
        END AS nstu_status_type_thai,

        CASE 
            WHEN CHARINDEX(' - ', nstu_des_thai) > 0
            THEN LTRIM(RTRIM(SUBSTRING(nstu_des_thai, CHARINDEX(' - ', nstu_des_thai) + 3, LEN(nstu_des_thai))))
            ELSE NULL
        END AS nstu_status_reason_thai,

        CASE 
            WHEN CHARINDEX(' - ', nstu_des_eng) > 0
            THEN LTRIM(RTRIM(LEFT(nstu_des_eng, CHARINDEX(' - ', nstu_des_eng) - 1)))
            ELSE LTRIM(RTRIM(nstu_des_eng))
        END AS nstu_status_type_eng,

        CASE 
            WHEN CHARINDEX(' - ', nstu_des_eng) > 0
            THEN LTRIM(RTRIM(SUBSTRING(nstu_des_eng, CHARINDEX(' - ', nstu_des_eng) + 3, LEN(nstu_des_eng))))
            ELSE NULL
        END AS nstu_status_reason_eng,

        CASE 
            WHEN LEN(sta_outdate_clean) = 8 THEN sta_outdate_clean
            ELSE NULL
        END AS sta_outdate

    FROM clean_data
)

SELECT 
    f.stu_id,
    f.snon_term,
    f.snon_year,
    f.snon_memo,
    f.nstu_id,
    f.nstu_status_type_thai,
    f.nstu_status_reason_thai,
    f.nstu_status_type_eng,
    f.nstu_status_reason_eng,
    f.sta_outdate
FROM final_data f
Left join silver_student_data sd
ON  f.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2558;

