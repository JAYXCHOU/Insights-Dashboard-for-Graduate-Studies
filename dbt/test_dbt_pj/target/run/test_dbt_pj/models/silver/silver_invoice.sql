
  
    USE [SeniorPJ_DB];
    USE [SeniorPJ_DB];
    
    

    

    
    USE [SeniorPJ_DB];
    EXEC('
        create view "dbo"."silver_invoice__dbt_tmp__dbt_tmp_vw" as SELECT
    inv_id,
    reg_year,
    reg_term,
    inv_date,
    --Replace(inv_date,''/'','''') AS inv_date_key, 
    --Replace(inv_pay_Date,''/'','''') AS inv_pay_date_key
    inv_pay_Date,
    -- inv_pay_status: '' '' (space) → NULL
    NULLIF(LTRIM(RTRIM(inv_pay_status)), '''')   AS inv_pay_status,
    inv_total,
    stu_id,
    inv_by,
    inv_pay_timeG

FROM bronze.invoice
WHERE TRY_CAST(stu_id AS INT) >= 5800000;
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

   


  