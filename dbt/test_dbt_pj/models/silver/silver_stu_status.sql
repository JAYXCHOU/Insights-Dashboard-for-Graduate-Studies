WITH joined_data AS (
    SELECT
        s.stu_id,
        s.snon_term,
        s.snon_year,
        s.snon_memo,
        s.nstu_id,
        d.nstu_des_thai,
        d.nstu_des_eng,
        s.sta_outdate
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

        -- ลบ /
        REPLACE(sta_outdate, '/', '') AS sta_outdate_clean
    FROM joined_data
),

final_data AS (
    SELECT
        stu_id,
        snon_term,
        snon_year,
        snon_memo,
        nstu_id,
        nstu_des_thai,
        nstu_des_eng,

        -- fix format date ให้เหลือ 8 ตัว
        CASE 
            WHEN LEN(sta_outdate_clean) = 8 THEN sta_outdate_clean
            ELSE NULL
        END AS sta_outdate
    FROM clean_data
)

SELECT *
FROM final_data;