FROM apache/airflow:3.1.6

USER root

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    unixodbc \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft signing key (NEW WAY)
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | tee /usr/share/keyrings/microsoft-prod.gpg > /dev/null

# Add Microsoft SQL Server repo
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] \
    https://packages.microsoft.com/debian/12/prod bookworm main" \
    > /etc/apt/sources.list.d/mssql-release.list

# Install ODBC Driver
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18

RUN pip install apache-airflow-providers-microsoft-mssql

USER airflow

RUN pip install --no-cache-dir \
    dbt-core \
    dbt-sqlserver \
    pyodbc \
    apache-airflow-providers-microsoft-mssql
