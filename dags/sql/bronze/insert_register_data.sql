INSERT INTO bronze.register(
    Stu_ID    ,
    Reg_Year  ,
    Reg_Term  ,
    Subj_ID   ,
    Subj_Rn   ,
    Reg_Credit,
    subj_nen  ,
    subj_nth  ,
    subj_id_th
)
SELECT
    Stu_ID    ,
    Reg_Year  ,
    Reg_Term  ,
    Subj_ID   ,
    Subj_Rn   ,
    Reg_Credit,
    subj_nen  ,
    subj_nth  ,
    subj_id_th
FROM
dbo.ICT_Register rg

WHERE NOT EXISTS(
    SELECT 1
    FROM bronze.register br
    WHERE rg.Stu_ID   = br.Stu_ID
    AND   rg.Reg_Year = br.Reg_Year
    AND   rg.Reg_Term = br.Reg_Term
    AND   rg.Subj_ID  = br.Subj_ID
    AND   rg.Subj_Rn  = br.Subj_Rn
);
