SELECT * FROM
(
    VALUES
    -- ('pd39','2','GR.39','สอบโครงร่าง', 'GR.39','staff'),
    -- ('pt1','3','GR.1','อนุมัติหัวข้อ','GR.1', 'staff'),
    -- ('pub2','4','GR.2','สอบวิทยานิพนธ์','GR.2','staff'),
    ('sub','10','e-thesis_sub','ส่งวิทยานิพนธ์','thesis submission','student'),
    ('aprv','10','e-thesis_aprv','อนุมัติของหลักสูตรและจนท','thesis approve','staff'),
    ('1','1','GR.44','บฑ.44 การแต่งตั้งอาจารย์ที่ปรึกษาโครงร่างวิทยานิพนธ์/สารนิพนธ์', 'GR.44 Appointment of Thesis/Thematic Paper Proposal Advisor','student'),
    ('2','2', 'GR.39'  ,'บฑ.39 กำหนดการสอบโครงร่างวิทยานิพนธ์/สารนิพนธ์ และคณะกรรมการสอบโครงร่างวิทยานิพนธ์/สารนิพนธ์', 'GR.39 Oral thesis proposal defence and committee / Oral thematic paper proposal defence and committee','student'),
    ('3','3', 'GR.1' ,'บฑ.1 การเสนอหัวข้อวิทยานิพนธ์/สารนิพนธ์ และคณะกรรมการที่ปรึกษาวิทยานิพนธ์/สารนิพนธ์' ,'GR.1 Thesis title and thesis advisory committee / Thematic paper title and thematic paper advisory committee','student'),
    ('4','4','GR.2','บฑ.2 กำหนดสอบวิทยานิพนธ์/สารนิพนธ์ และคณะกรรมการสอบวิทยานิพนธ์/สารนิพนธ์', 'GR.2 Oral thesis defence and committee / Oral thematic paper defence and committee','student'),
    ('5','5', 'GR.35' ,'บฑ.35 กำหนดการสอบวัดคุณสมบัติ และคณะกรรมการสอบวัดคุณสมบัติ', 'GR.35 Qualify examination and committee','student'),
    ('6','6', 'GR.42' ,'บฑ.42 แบบฟอร์มการรายงานผลและประเมินผลความก้าวหน้าการทำวิทยานิพนธ์ / สารนิพนธ์', 'GR.42 The Report and Assessment of a Students Progress and Research Performance for Thesis / Thematic Paper','student') ,
    ('7','7', 'GR.27' ,'บฑ.27 กำหนดการสอบประมวลความรู้ และคณะกรรมการสอบประมวลความรู้', 'GR.27 Comprehensive examination and committee','student'),
    ('8','8', 'GR.49' ,'บฑ 49 การขอเปลี่ยนแปลงหัวข้อวิทยานิพนธ์/สารนิพนธ์', 'Title of Thesis/Thematic Paper','student'),
    ('10','10','e-thesis_sub','การส่งรูปเล่มวิทยานิพนธ์/สารนิพนธ์', 'e-Thesis Submission','student'),
    ('22','22', 'GR.5' ,'บฑ.5 การเสนอให้บัณฑิตวิทยาลัย มหาวิทยาลัยมหิดล ขออนุมัติปริญญาให้นักศึกษา', 'GR.5 Requesting degree','student'),
    ('23','23', 'GR.40' ,'บฑ.40 แจ้งความประสงค์ขอเผยแพร่ บทคัดย่อวิทยานิพนธ์ (Abstract) ทาง Internet', 'GR.40 Publication of Thesis on Mahidol Website','student'),
    ('24','24', 'COA' ,'เอกสารรับรองทางจริยธรรม (COA) หรือเอกสารที่แสดงว่าไม่ต้องผ่านการพิจารณาทางจริยธรรม จากคณะกรรมการจริยธรรมหรือศูนย์ส่งเสริมจริยธรรม', 'Certificate of Ethics Approval (COA), or  document stated that your research is exempted from Ethics Consideration issued by corresponding Ethics Committee','student'),
    ('28','28', 'GRAS.39' ,'บฑกศ.39 คำร้องขอหนังสือเชิญผู้ทำ หน้าที่เพื่อให้ได้มาซึ่งหัวข้อวิทยานิพนธ์/การค้นคว้าอิสระ','GRAS.39 Request to Inviting the distinguished responsible for obtaining a thesis or independent research topic','student')

) AS dim_milestone (ID_form, ID_form_sum, ID_form_name,form_name_th, form_name_en, by_who)

-- Select DISTINCT
--     ID_form,
--     form_name_th,
--     form_name_en
-- FROM {{ref('silver_thesis_data')}}