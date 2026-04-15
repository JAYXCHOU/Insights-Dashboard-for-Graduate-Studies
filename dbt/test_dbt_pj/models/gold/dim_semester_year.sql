Select DISTINCT
  Reg_Year,
  Reg_Term
FROM silver_grade_stu
UNION 

Select DISTINCT
  Reg_Year,
  Reg_Term
FROM silver_register
UNION 

Select DISTINCT
  Reg_Year,
  Reg_Term
FROM silver_invoice

