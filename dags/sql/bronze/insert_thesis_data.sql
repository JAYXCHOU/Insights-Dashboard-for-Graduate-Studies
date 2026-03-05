Insert into bronze.thesis(
    stu_id,
    ID_form,
    form_name_th,
    form_name_en,
    step_id,
    step,
    add_date,
    submit_date ,
    PD_DateNo,
    pd_DatePass ,
    pt_dateno,
    pub_DateNo,
    pub_DatePass
)
SELECT 
    stu_id,
    ID_form,
    form_name_th,
    form_name_en,
    step_id,
    step,
    add_date,
    submit_date ,
    PD_DateNo,
    pd_DatePass ,
    pt_dateno,
    pub_DateNo,
    pub_DatePass
From 
dbo.ICT_Thesis_Data td

-- WHERE NOT EXISTS(
--     SELECT 1 FROM 
--     bronze.thesis t
--     WHERE td.stu_id = t.stu_id
-- )
