from airflow import DAG
# from airflow.operation.python import PythonOPerator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import pandas as pd
import uuid

with DAG(
    dag_id="bronze_silver_gold",
    start_date=datetime(2026,2,23),
    catchup=False
) as dag:

    create_schema = SQLExecuteQueryOperator(
        task_id= "create_schema",
        conn_id = "mssql_default",
        sql="sql/setup_schema.sql"
    )

    create_student_table = SQLExecuteQueryOperator(
        task_id="create_bronz_student_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_student_table.sql"
    )

    create_scholar_table = SQLExecuteQueryOperator(
        task_id="create_bronze_scholar_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_scholar_table.sql"
    )

    craete_curriculum_table = SQLExecuteQueryOperator(
        task_id="create_bronze_curriculum_table",
        conn_id="mssql_default",
        sql="sql/bronze/craete_curriculum_table.sql"
    )

    create_curriculum_cyc_table = SQLExecuteQueryOperator(
        task_id="create_bronze_curriculum_cyc_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_curriculum_cyc_table.sql"
    )

    create_thesis_table = SQLExecuteQueryOperator(
        task_id="create_bronze_thesis_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_thesis_table.sql"
    )

    insert_curriculum = SQLExecuteQueryOperator(
        task_id="insert_curriculum",
        conn_id="mssql_default",
        sql="sql/bronze/insert_curr_data.sql"
    )

    insert_student = SQLExecuteQueryOperator(
        task_id="insert_student",
        conn_id="mssql_default",
        sql="sql/bronze/insert_stu_data.sql"
    )
    insert_scholar = SQLExecuteQueryOperator(
        task_id = "insert_scholar",
        conn_id = "mssql_default",
        sql="sql/bronze/insert_scholar_data.sql"
    )
    insert_curriculum_cyc = SQLExecuteQueryOperator(
        task_id = "insert_curriculum_cyc",
        conn_id = "mssql_default",
        sql="sql/bronze/insert_curr_cyc_data.sql"
    )
    insert_thesis = SQLExecuteQueryOperator(
        task_id = "insert_thesis",
        conn_id = "mssql_default",
        sql="sql/bronze/insert_thesis_data.sql"
    )

    dbt_run_silver= BashOperator(
    task_id="dbt_run_silver",
    bash_command="cd /opt/airflow/dbt/test_dbt_pj && dbt run --select silver"
    )
    dbt_run_gold= BashOperator(
    task_id="dbt_run_gold",
    bash_command="cd /opt/airflow/dbt/test_dbt_pj && dbt run --select gold"
    )

create_table = [
    create_student_table,
    create_scholar_table,
    craete_curriculum_table,
    create_curriculum_cyc_table,
    create_thesis_table
]

insert_data = [
    insert_student,
    insert_scholar,
    insert_curriculum,
    insert_curriculum_cyc,
    insert_thesis
]

create_schema >> create_table 

for create_task, insert_task in zip(create_table, insert_data):
    create_task >> insert_task

insert_data >> dbt_run_silver >> dbt_run_gold