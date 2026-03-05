IF NOT EXISTS(
    SELECT * from sys.tables 
    WHERE name = 'thesis' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.thesis(
        stu_id                         char(7),
        ID_form                        int,
        form_name_th                   varchar(250),
        form_name_en                   varchar(250),
        step_id                        int,
        step                           varchar(27),
        add_date                       varchar(20),
        submit_date                    varchar(20),
        PD_DateNo                      char(10),
        pd_DatePass                    char(10),
        pt_dateno                      char(10),
        pub_DateNo                     char(10),
        pub_DatePass                   char(10),
    );
    PRINT 'Created bronze thesis table';
END        
ELSE
    PRINT 'bronze thesis table already exists';