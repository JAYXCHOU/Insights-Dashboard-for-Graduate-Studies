IF NOT EXISTS(
    SELECT * from sys.tables
    WHERE name = 'invoice' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.invoice(
        inv_id                         char(10),
        reg_year                       char(4),
        reg_term                       char(1),
        inv_date                       nvarchar(20),
        inv_pay_Date                   nvarchar(20),
        inv_pay_status                 char(1),
        inv_total                      float,
        stu_id                         char(7),
        inv_by                         nvarchar(50),
        inv_pay_timeG                  nvarchar(50),
        GRID                           char(1),
        loaded_at              DATETIME           DEFAULT GETDATE()
    );
    PRINT 'Created bronze invoice table';
END
ELSE
    PRINT 'bronze invoice table already exists';
