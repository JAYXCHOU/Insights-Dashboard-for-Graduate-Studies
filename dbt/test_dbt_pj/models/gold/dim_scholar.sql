Select Distinct
    Sch_ID,
    Scholar_thai,
    Scholar_eng ,
    Amount
FROM {{ref('silver_scholar_data')}}