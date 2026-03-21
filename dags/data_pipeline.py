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

    create_curriculum_table = SQLExecuteQueryOperator(
        task_id="create_bronze_curriculum_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_curriculum_table.sql"
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

    
    create_thesis_approve_table = SQLExecuteQueryOperator(
        task_id="create_bronze_thesis_approve_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_thesis_approve_table.sql"
    )
 
    create_thesis_submission_table = SQLExecuteQueryOperator(
        task_id="create_bronze_thesis_submission_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_thesis_submission_table.sql"
    )

    create_gradestu_table = SQLExecuteQueryOperator(
        task_id="create_bronze_gradestu_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_gradestu_table.sql"
    )
 
    create_invoice_table = SQLExecuteQueryOperator(
        task_id="create_bronze_invoice_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_invoice_table.sql"
    )
 
    create_subject_table = SQLExecuteQueryOperator(
        task_id="create_bronze_subject_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_subject_table.sql"
    )
 
    create_register_table = SQLExecuteQueryOperator(
        task_id="create_bronze_register_table",
        conn_id="mssql_default",
        sql="sql/bronze/create_register_table.sql"
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

    insert_thesis_approve = SQLExecuteQueryOperator(
        task_id = "insert_thesis_approve",
        conn_id = "mssql_default",
        sql="sql/bronze/insert_thesis_approve_data.sql"
    )
    insert_thesis_submission = SQLExecuteQueryOperator(
        task_id = "insert_thesis_submission",
        conn_id = "mssql_default",
        sql="sql/bronze/insert_thesis_submission_data.sql"
    )
    insert_gradestu = SQLExecuteQueryOperator(
        task_id="insert_gradestu",
        conn_id="mssql_default",
        sql="sql/bronze/insert_gradestu_data.sql"
    )
 
    insert_invoice = SQLExecuteQueryOperator(
        task_id="insert_invoice",
        conn_id="mssql_default",
        sql="sql/bronze/insert_invoice_data.sql"
    )
 
    insert_subject = SQLExecuteQueryOperator(
        task_id="insert_subject",
        conn_id="mssql_default",
        sql="sql/bronze/insert_subject_data.sql"
    )
 
    insert_register = SQLExecuteQueryOperator(
        task_id="insert_register",
        conn_id="mssql_default",
        sql="sql/bronze/insert_register_data.sql"
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
    create_curriculum_table,
    create_curriculum_cyc_table,
    create_thesis_table,
    create_thesis_approve_table,
    create_thesis_submission_table,
    create_gradestu_table,
    create_invoice_table,
    create_subject_table,
    create_register_table
]

insert_data = [
    insert_student,
    insert_scholar,
    insert_curriculum,
    insert_curriculum_cyc,
    insert_thesis,
    insert_thesis_approve,
    insert_thesis_submission,
    insert_gradestu,
    insert_invoice,
    insert_subject,
    insert_register
]

create_schema >> create_table 

for create_task, insert_task in zip(create_table, insert_data):
    create_task >> insert_task

insert_data >> dbt_run_silver >> dbt_run_gold