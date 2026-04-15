
  
    USE [SeniorPJ_DB];
    USE [SeniorPJ_DB];
    
    

    

    
    USE [SeniorPJ_DB];
    EXEC('
        create view "dbo"."silver_invoice__dbt_tmp__dbt_tmp_vw" as SELECT
    i.inv_id,
    i.reg_year,
    i.reg_term,
    i.inv_date,
    --Replace(inv_date,''/'','''') AS inv_date_key, 
    --Replace(inv_pay_Date,''/'','''') AS inv_pay_date_key
    i.inv_pay_Date,
    -- inv_pay_status: '' '' (space) → NULL
    NULLIF(LTRIM(RTRIM(i.inv_pay_status)), '''')   AS inv_pay_status,
    i.inv_total,
    i.stu_id,
    i.inv_by,
    i.inv_pay_timeG

FROM bronze.invoice i
Left join silver_student_data sd
ON  i.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2558;
    ')

EXEC('
            SELECT * INTO "SeniorPJ_DB"."dbo"."silver_invoice__dbt_tmp" FROM "SeniorPJ_DB"."dbo"."silver_invoice__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS dbo.silver_invoice__dbt_tmp__dbt_tmp_vw')



    
    use [SeniorPJ_DB];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'dbo_silver_invoice__dbt_tmp_cci'
        AND object_id=object_id('dbo_silver_invoice__dbt_tmp')
    )
    DROP index "dbo"."silver_invoice__dbt_tmp".dbo_silver_invoice__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX dbo_silver_invoice__dbt_tmp_cci
    ON "dbo"."silver_invoice__dbt_tmp"

   


  