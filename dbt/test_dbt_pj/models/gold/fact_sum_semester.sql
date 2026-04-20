with count_regis AS(
    Select
        stu_id,
        Reg_Year,
        Reg_Term,
        Count(Subj_ID) as count_reg_subj,
        Sum(Reg_Credit) as sum_Reg_Credit
    FROM 
        silver_register
    GROUP BY stu_id,Reg_Year,Reg_Term
),

count_grade AS(
    Select 
        stu_id,
        Reg_Year,
        Reg_Term,
        Count(Subj_ID) as count_grade_subj,
        Sum(Credit) as sum_credit
    FROM silver_grade_stu
    GROUP BY stu_id,Reg_Year,Reg_Term
),

count_invoice AS(
    SELECT 
	    stu_id, 
	    reg_year, 
	    reg_term,
	    count(inv_id) AS count_invoice
    FROM silver_invoice
    group by stu_id, reg_year, reg_term
),

union_grade_invoice_regis AS(
    SELECT 
        stu_id,
        Reg_Year,
        Reg_Term
    FROM count_regis
    UNION

    SELECT
        stu_id,
        Reg_Year,
        Reg_Term

    FROM count_grade

    UNION

    SELECT
        stu_id, 
	    reg_year, 
	    reg_term
    FROM
    count_invoice

),
final AS(    
SELECT
    u.stu_id,
    u.Reg_Year,
    u.Reg_Term,

    r.count_reg_subj,
    r.sum_Reg_Credit,

    g.count_grade_subj,
    g.sum_credit,

    i.count_invoice,

    CASE
        WHEN count_invoice > 0 THEN 'จ่ายค่าเทอม'
        ELSE 'ยังไม่มีการจ่ายค่าเทอม'
    END AS has_payment

FROM union_grade_invoice_regis u

LEFT JOIN count_regis  r ON
    u.stu_id   = r.stu_id AND
    u.Reg_Year  = r.Reg_Year AND
    u.Reg_Term  = r.Reg_Term 

LEFT JOIN count_grade  g ON
    u.stu_id   = g.stu_id AND
    u.Reg_Year  = g.Reg_Year AND
    u.Reg_Term  = g.Reg_Term 

LEFT JOIN count_invoice  i ON
    u.stu_id   =  i.stu_id AND
    u.Reg_Year  = i.Reg_Year AND
    u.Reg_Term  = i.Reg_Term 
),
join_dim_student AS(
    SELECT
    s.stu_id,
    s.cur_id,
    s.cur_rn,
    s.study_type,
    s.stu_prg_plan,

    y.Reg_Year,
    y.Reg_Term,
    f.count_reg_subj,
    f.sum_Reg_Credit,
    f.count_grade_subj,
    f.sum_credit,
    f.count_invoice,
    f.has_payment
    from final f
    Left join dim_student s ON
        f.stu_id = s.stu_id

LEFT JOIN dim_semester_year y ON
    f.Reg_Year = y.Reg_Year AND
    f.Reg_Term = y.Reg_Term

)
SELECT 
    s.stu_id,
    dc.curriculum_key,
    s.Reg_Year,
    s.Reg_Term,
    s.count_reg_subj,
    s.sum_Reg_Credit,
    s.count_grade_subj,
    s.sum_credit,
    s.count_invoice,
    s.has_payment
from join_dim_student s
LEFT JOIN {{ref('dim_curriculum')}} dc
    ON s.cur_id = dc.cur_id
    AND s.cur_rn = dc.cur_rn
    AND s.stu_prg_plan = dc.study_plan
    AND s.study_type = dc.study_type

-- student_semester AS (
--     SELECT 
--         ds.stu_id,
--         dsy.Reg_Year,
--         dsy.Reg_Term
--     FROM dim_student ds
--     CROSS JOIN dim_semester_year dsy
-- )

-- SELECT 
--     ss.stu_id,
--     ss.Reg_Year,
--     ss.Reg_Term,
    
--     r.count_reg_subj,
--     r.sum_Reg_Credit,

--     g.count_grade_subj,
--     g.sum_credit

-- FROM student_semester ss

-- LEFT JOIN count_regis r
--     ON ss.stu_id = r.stu_id
--     AND ss.Reg_Year = r.Reg_Year
--     AND ss.Reg_Term = r.Reg_Term

-- LEFT JOIN count_grade g
--     ON ss.stu_id = g.stu_id
--     AND ss.Reg_Year  = g.Reg_Year
--     AND ss.Reg_Term   = g.Reg_Term

