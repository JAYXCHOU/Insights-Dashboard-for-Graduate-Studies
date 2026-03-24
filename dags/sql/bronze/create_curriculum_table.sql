IF NOT EXISTS(
    SELECT * from sys.tables 
    WHERE name = 'curriculum' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.curriculum(
        cur_id                         char(5),
        cur_rn                         char(2),
        study_type                     char(1),
        deg_lev_id                     char(1),
        [ชื่อหลักสูตร (th)]              varchar(200),
        [ชื่อหลักสูตร (en)]              varchar(200),
        ระดับ                          char(100),
        fac_id                         char(2),
        [คณะ (th)]                       varchar(255),
        [คณะ (en)]                       varchar(350),
        cur_pla_a1                     char(1),
        cur_pla_a2                     char(1),
        cur_pla_b                      char(1),
        cur_pla_1_1                    char(1),
        cur_pla_1_2                    char(1),
        cur_pla_2_1                    char(1),
        cur_pla_2_2                    char(1),
        [เว็บไซต์]                       NVARCHAR(MAX),
        [ชื่่อปริญญา (th)]               varchar(200),
        [ชื่่อปริญญา (en)]               varchar(200),
        Brn_ID                         char(4),
        Sub_Brn_ID                     char(2),
        [วิชาเอก (th)]                   char(100),
        [วิชาเอก (en)]                  char(100),
        [จุดเด่นของหลักสูตร (th)]        NVARCHAR(MAX),
        [จุดเด่นของหลักสูตร (en)]          NVARCHAR(MAX),
        [คุณสมบัติของผุู้เข้าศึกษา (th) ]     NVARCHAR(MAX),
        [คุณสมบัติของผุู้เข้าศึกษา (en) ]      NVARCHAR(MAX),
        cur_type_th                    char(1),
        cur_type_i                     char(1),
        cur_desth                      NVARCHAR(MAX),
        [อาชีพที่สามารถประกอบได้หลังสำเร็จการศึกษา (th)]      NVARCHAR(MAX),
        [อาชีพที่สามารถประกอบได้หลังสำเร็จการศึกษา (en)]      NVARCHAR(MAX),
        groupN_id                      char(2),
        [กลุ่มการศึกษาแบ่งตามมหาวิทยาลัย (3 กลุ่ม)]     varchar(150),
        [ภาษาที่ใช้ทำวิทยานิพนธ์ (T/E)]  varchar(1),
    );
    PRINT 'Created bronze curriculum table';
END        
ELSE
    PRINT 'bronze curriculum table already exists';