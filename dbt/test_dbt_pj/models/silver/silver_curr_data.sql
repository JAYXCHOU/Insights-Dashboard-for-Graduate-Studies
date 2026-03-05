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
   -- CASE cur_pla_col
   --    WHEN 'cur_pla_a1' THEN 'ก1'
   --    WHEN 'cur_pla_a2'THEN 'ก2'
   --    WHEN 'cur_pla_b' THEN 'ข'
   --    WHEN 'cur_pla_1_1' THEN '1.1'
   --    WHEN 'cur_pla_1_2' THEN '1.2'
   --    WHEN 'cur_pla_2_1' THEN '2.1'
   --    WHEN 'cur_pla_2_2' THEN '2.2'
   --    ELSE 'other'
   -- END AS study_plan,
  v.study_plan,
  c.[เว็บไซต์ ] AS web,
  c.[ชื่่อปริญญา (th) ] AS deg_name_th,
  c.[ชื่่อปริญญา (en) ] AS deg_name_en,
  c.Brn_ID,
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