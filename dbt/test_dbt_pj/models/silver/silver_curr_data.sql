WITH cleaned_curr As(
  SELECT
  c.cur_id,
  c.cur_rn,
  c.study_type,
  c.deg_lev_id,
  c.[ชื่อหลักสูตร (th) ] AS cur_name_th,
  c.[ชื่อหลักสูตร (en) ] AS cur_name_en,
  c.[ระดับ] AS deg_level,
  c.fac_id,
  c.[คณะ (th) ] AS fac_name_th,
  c.[คณะ (en) ] AS fac_name_en,
  c.cur_pla_a1,
  c.cur_pla_a2,
  c.cur_pla_b ,
  c.cur_pla_1_1,
  c.cur_pla_1_2,
  c.cur_pla_2_1,
  c.cur_pla_2_2,
  v.study_plan,
  c.[เว็บไซต์ ] AS web,
  c.[ชื่่อปริญญา (th) ] AS deg_name_th,
  c.[ชื่่อปริญญา (en) ] AS deg_name_en,
  ISNULL(c.Brn_ID,'00') AS Brn_ID,
  c.Sub_Brn_ID,
  c.[วิชาเอก (th) ] AS major_name_th,
  c.[วิชาเอก (en) ] AS major_name_en,
  c.[จุดเด่นของหลักสูตร (th) ] AS strength_name_th,
  c.[จุดเด่นของหลักสูตร (en) ] AS strength_name_en,
  c.[คุณสมบัติของผุู้เข้าศึกษา (th) ] AS prop_name_th,
  c.[คุณสมบัติของผุู้เข้าศึกษา (en) ] AS prop_name_en,
  c.cur_type_th,
  c.cur_type_i,
  c.cur_desth,
  c.[อาชีพที่สามารถประกอบได้หลังสำเร็จการศึกษา (th) ] AS future_occup_th,
  c.[อาชีพที่สามารถประกอบได้หลังสำเร็จการศึกษา (en) ] AS future_occup_en,
  c.groupN_id ,
  c.[กลุ่มการศึกษาแบ่งตามมหาวิทยาลัย (3 กลุ่ม) ] AS study_group_type,
  c.[ภาษาที่ใช้ทำวิทยานิพนธ์ (T/E) ] AS lang
FROM
bronze.curriculum c
CROSS APPLY(
   VALUES
      (c.cur_pla_a1, 'ก1'),
      (c.cur_pla_a2, 'ก2'),
      (c.cur_pla_b,  'ข'),
      (c.cur_pla_1_1, '1.1'),
      (c.cur_pla_1_2, '1.2'),
      (c.cur_pla_2_1, '2.1'),
      (c.cur_pla_2_2, '2.2')
) v(flag, study_plan)
WHERE v.flag = 'T'
),

clean_cur_type AS(
  SELECT
    c.cur_id,
    c.cur_rn,
    c.study_type,
    c.deg_lev_id,
    c.cur_name_th,
    c.cur_name_en,
    c.deg_level,
    c.fac_id,
    c.fac_name_th,
    c.fac_name_en,
    c.cur_pla_a1,
    c.cur_pla_a2,
    c.cur_pla_b,
    c.cur_pla_1_1,
    c.cur_pla_1_2,
    c.cur_pla_2_1,
    c.cur_pla_2_2,
    c.study_plan,
    c.cur_type_th,
    c.cur_type_i,
    v.cur_type_lang,
    c.web,
    c.deg_name_th,
    c.deg_name_en,
    c.Brn_ID,
    c.Sub_Brn_ID,
    c.major_name_th,
    c.major_name_en,
    c.groupN_id,
    c.study_group_type,
    c.lang
  FROM cleaned_curr c
  CROSS APPLY(
   VALUES
      (c.cur_type_th, 'หลักสูตรไทย'),
      (c.cur_type_i, 'หลักสูตรนานาชาติ')
) v(flag, cur_type_lang)
WHERE v.flag = 'T'
),
study_plan AS(
  SELECT 
    cur_id,
    cur_rn,
    study_type,
    deg_lev_id,
    cur_name_th,
    cur_name_en,
    deg_level,
    fac_id,
    fac_name_th,
    fac_name_en,
    cur_pla_a1,
    cur_pla_a2,
    cur_pla_b,
    cur_pla_1_1,
    cur_pla_1_2,
    cur_pla_2_1,
    cur_pla_2_2,
    study_plan,
    -- CASE 
    --   WHEN org_study_plan Is NULL THEN NULL
    --   ELSE Left(TRIM(org_study_plan),1) 
    -- End AS study_plan,
    cur_type_th,
    cur_type_i,
    cur_type_lang,
    web,
    deg_name_th,
    deg_name_en,
    Brn_ID,
    Sub_Brn_ID,
    major_name_th,
    major_name_en,
    groupN_id,
    study_group_type,
    lang
  From clean_cur_type
)
Select * From study_plan



