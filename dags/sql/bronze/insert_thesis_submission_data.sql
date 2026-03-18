Insert into bronze.thesis_submission(
    sub_stu,
    save_time
)
SELECT
    ts.sub_stu,
    ts.save_time
From
dbo.ICT_Thesis_submission ts
WHERE NOT EXISTS (
    SELECT 1
    FROM bronze.thesis_submission bs
    WHERE 
        ts.sub_stu = bs.sub_stu
        AND ts.save_time = bs.save_time
);