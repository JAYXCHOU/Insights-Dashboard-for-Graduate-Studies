from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id="test_dbt_pipeline",
    start_date=datetime(2026, 1, 20),
    schedule="0 1 * * 1",
    catchup=False,
) as dag:

    run_dbt = BashOperator(
        task_id="run_dbt_model",
        bash_command="cd /opt/airflow/dbt/test_dbt_pj && dbt run"
    )

    run_dbt
