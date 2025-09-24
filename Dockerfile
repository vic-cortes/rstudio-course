# Use official SQL Server (Linux) image — you can change the version if needed
FROM mcr.microsoft.com/mssql/server:2022-latest

ENV ACCEPT_EULA=Y
# Change to something secure
ENV MSSQL_SA_PASSWORD=MiPass@1234   

# Copy the .mdf/.ldf database files and the attach script into the container
COPY data/real_db.mdf /var/opt/mssql/data/real_db.mdf
COPY data/real_db.ldf /var/opt/mssql/data/real_db.ldf

# Enable BuildKit when building: DOCKER_BUILDKIT=1 docker build ...
COPY --chmod=755 attach_db.sh /usr/src/app/attach_db.sh

# The ENTRYPOINT ensures that SQL Server stays in the foreground,
# and that the attach script runs at startup
ENTRYPOINT /usr/src/app/attach_db.sh & /opt/mssql/bin/sqlservr