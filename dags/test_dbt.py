from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id = "test_dbt",
    schedule = None,
    catchup=False,
) as dag:
    
    dbt_debug = BashOperator(
        task_id ="dbt_debug",
        bash_command = """
        cd /opt/airflow/dbt/test_dbt_pj
        dbt debug
        """
    )

    dbt_run = BashOperator(
        task_id = "dbt_run",
        bash_command="""
        cd /opt/airflow/dbt/test_dbt_pj
        dbt run
        """
    )
dbt_debug >> dbt_run
