INSERT INTO bronze.scholar(
    stu_ID      ,
    Sch_ID      ,
    Scholar_thai,
    Scholar_eng ,
    Rec_Syear   ,
    F_Term      ,
    Rec_Eyear   ,
    L_Term      ,
    GetDate     ,
    FinalDate   ,
    Amount
)
SELECT
    stu_ID      ,
    Sch_ID      ,
    Scholar_thai,
    Scholar_eng ,
    Rec_Syear   ,
    F_Term      ,
    Rec_Eyear   ,
    L_Term      ,
    GetDate     ,
    FinalDate   ,
    Amount
FROM
dbo.ICT_Scholar_Data sd

