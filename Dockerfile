# Use official SQL Server (Linux) image — you can change the version if needed
FROM mcr.microsoft.com/mssql/server:2022-latest

ENV ACCEPT_EULA=Y
# Change to something secure
ENV MSSQL_SA_PASSWORD=TuPasswordSegura   

# Copy the .mdf/.ldf database files and the attach script into the container
COPY data/reald_db.mdf /var/opt/mssql/data/reald_db.mdf
COPY data/reald_db.ldf /var/opt/mssql/data/reald_db.ldf
COPY attach_db.sh /usr/src/app/attach_db.sh

RUN chmod +x /usr/src/app/attach_db.sh

# The ENTRYPOINT ensures that SQL Server stays in the foreground,
# and that the attach script runs at startup
ENTRYPOINT /usr/src/app/attach_db.sh & /opt/mssql/bin/sqlservr