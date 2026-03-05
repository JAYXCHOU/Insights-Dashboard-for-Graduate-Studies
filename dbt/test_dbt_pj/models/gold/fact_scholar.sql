SELECT
    s.stu_id,
    sc.Sch_ID,
    ssd.Amount
FROM{{ref('silver_scholar_data')}} ssd

LEFT JOIN {{ ref('dim_scholar')}} sc
 ON ssd.Sch_ID = sc.Sch_ID

LEFT JOIN {{ ref('dim_student')}} s
 ON ssd.stu_id = s.stu_ID
