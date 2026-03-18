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

WHERE NOT EXISTS(
    SELECT 1
    FROM bronze.scholar bs
    WHERE sd.stu_id = bs.stu_id
    AND sd.Sch_ID = bs.Sch_ID
    AND sd.Rec_Syear = bs.Rec_Syear
    AND sd.F_Term = bs.F_Term
);
