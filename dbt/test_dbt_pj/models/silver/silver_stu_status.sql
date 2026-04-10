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
        snon_term,
        snon_year,
        snon_memo,
        nstu_id,
        nstu_des_thai,
        nstu_des_eng,
        REPLACE(sta_outdate, '/', '') AS sta_outdate_clean
    FROM joined_data
    WHERE rn = 1  -- เอาแค่แถวแรกของแต่ละกลุ่ม
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

SELECT *
FROM final_data
WHERE TRY_CAST(stu_id AS INT) >= 5800000;