from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime

with DAG(
    dag_id="test_mssql_query",
    # start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["test", "mssql"],
) as dag:

    test_connection = SQLExecuteQueryOperator(
        task_id="test_mssql_connection",
        conn_id="test_sqlserver",   
        sql="SELECT DB_NAME() AS current_db;",
    )