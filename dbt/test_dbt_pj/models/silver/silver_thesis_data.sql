SELECT
    stu_id,
    ID_form,
    form_name_th,
    form_name_en,
    step_id,
    step,
    TRY_CONVERT(DATE, add_date, 111) AS add_date,
    CAST(
        CONVERT(VARCHAR(8), 
            TRY_CONVERT(DATE, add_date, 111),112)
    AS INT) AS add_date_key,
    
    TRY_CONVERT(DATE, submit_date, 111) AS submit_date,
    CAST(
        CONVERT(VARCHAR(8), 
            TRY_CONVERT(DATE, submit_date, 111),112)
    AS INT) AS submit_date_key,
    PD_DateNo,
    pd_DatePass ,
    pt_dateno,
    pub_DateNo,
    pub_DatePass
FROM
bronze.thesis