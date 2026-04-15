
  
    USE [SeniorPJ_DB];
    USE [SeniorPJ_DB];
    
    

    

    
    USE [SeniorPJ_DB];
    EXEC('
        create view "dbo"."silver_grade_stu__dbt_tmp__dbt_tmp_vw" as SELECT
    g.Stu_ID  AS stu_id,
    g.Reg_Year,
    g.Reg_Term,
    g.Subj_ID,
    g.Subj_Rn,
    g.Credit,
    -- TRIM trailing/leading spaces ออกจากเกรด
    -- NULL และ empty string → NULL
    NULLIF(LTRIM(RTRIM(g.Reg_Grad)), '''')   AS Reg_Grad

FROM bronze.grade_stu g
Left join silver_student_data sd
ON  g.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2558;
    ')

EXEC('
            SELECT * INTO "SeniorPJ_DB"."dbo"."silver_grade_stu__dbt_tmp" FROM "SeniorPJ_DB"."dbo"."silver_grade_stu__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS dbo.silver_grade_stu__dbt_tmp__dbt_tmp_vw')



    
    use [SeniorPJ_DB];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'dbo_silver_grade_stu__dbt_tmp_cci'
        AND object_id=object_id('dbo_silver_grade_stu__dbt_tmp')
    )
    DROP index "dbo"."silver_grade_stu__dbt_tmp".dbo_silver_grade_stu__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX dbo_silver_grade_stu__dbt_tmp_cci
    ON "dbo"."silver_grade_stu__dbt_tmp"

   


  