#!/bin/bash
# Wait for SQL Server to be ready (adjust the time if necessary)
sleep 15s

# Try to attach the database
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" \
    -Q "CREATE DATABASE reald_db ON (FILENAME = '/var/opt/mssql/data/reald_db.mdf'), (FILENAME = '/var/opt/mssql/data/reald_db.ldf') FOR ATTACH;"

# Keep the script alive (optionally you could use a loop or just exit)
/bin/bash