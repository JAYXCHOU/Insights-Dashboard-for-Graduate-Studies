INSERT INTO bronze.grade_stu(
    Stu_ID   ,
    Reg_Year ,
    Reg_Term ,
    Subj_ID  ,
    Subj_Rn  ,
    Credit   ,
    Reg_Grad
)
SELECT
    Stu_ID   ,
    Reg_Year ,
    Reg_Term ,
    Subj_ID  ,
    Subj_Rn  ,
    Credit   ,
    Reg_Grad
FROM
dbo.ICT_GradeStu gs

WHERE NOT EXISTS(
    SELECT 1
    FROM bronze.grade_stu bg
    WHERE gs.Stu_ID   = bg.Stu_ID
    AND   gs.Reg_Year = bg.Reg_Year
    AND   gs.Reg_Term = bg.Reg_Term
    AND   gs.Subj_ID  = bg.Subj_ID
    AND   gs.Subj_Rn  = bg.Subj_Rn
);
