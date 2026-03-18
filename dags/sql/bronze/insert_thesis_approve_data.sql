Insert into bronze.thesis_approve(
    stu_id,
    rn,
    Gr_ID,
    status_apv,
    status_apv_desc,
    QA,
    QA_desc,
    QA_text,
    apv_time
)
SELECT
    ta.stu_id,
    ta.rn,
    ta.Gr_ID,
    ta.status_apv,
    ta.status_apv_desc,
    ta.QA,
    ta.QA_desc,
    ta.QA_text,
    ta.apv_time
From
dbo.ICT_Thesis_approve ta
WHERE NOT EXISTS (
    SELECT 1
    FROM bronze.thesis_approve ba
    WHERE 
        ta.stu_id = ba.stu_id
        AND ta.rn = ba.rn
);
 