WITH ranked AS (
    SELECT
        sub_stu AS stu_id,
        'sub' as ID_form,
        'sub' as step_id,
        save_time,
        -- CONVERT(VARCHAR(10), save_time, 111) AS add_date
        CONVERT(VARCHAR(10), CAST(save_time AS DATETIME),112) AS add_date_key,
        CONVERT(VARCHAR(10), CAST(save_time AS DATETIME),111) AS add_date,

        ROW_NUMBER() OVER (
            PARTITION BY sub_stu, CAST(save_time AS DATE)
            ORDER BY save_time
        ) AS rn


    FROM bronze.thesis_submission
),

final As(
SELECT
    stu_id,
    ID_form,
    step_id,
    save_time,
    add_date_key,
    add_date
FROM ranked
WHERE rn = 1
)

Select 
    f.stu_id,
    f.ID_form,
    f.step_id,
    f.save_time,
    f.add_date_key,
    f.add_date
from final f
Left join silver_student_data sd
ON  f.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2015;
