
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Postgres Connection Saturation
---

This incident type occurs when the number of connections to a Postgres server is approaching its limit and may cause a saturation of the connection pool. This can lead to slow queries, timeouts, and other performance issues. It is important to monitor and manage the number of connections to ensure the smooth functioning of the database.

### Parameters
```shell
# Environment Variables

export DATABASE_NAME="PLACEHOLDER"

export NEW_CONNECTION_LIMIT="PLACEHOLDER"

export PATH_TO_POSTGRESQL_CONF="PLACEHOLDER"


```

## Debug

### Check the current number of connections to the Postgres instance
```shell
sudo -u postgres psql -c "select count(*) from pg_stat_activity;" ${DATABASE_NAME}
```

### Check the maximum number of connections allowed by the Postgres instance
```shell
sudo -u postgres psql -c "show max_connections;" ${DATABASE_NAME}
```

### Check the current value of the connection limit for each user
```shell
sudo -u postgres psql -c "select usename, current_connections from pg_stat_activity join pg_user on pg_stat_activity.usename = pg_user.usename where pg_stat_activity.datname = '${DATABASE_NAME}';" ${DATABASE_NAME}
```

### Check if there are any idle connections that can be closed
```shell
sudo -u postgres psql -c "select * from pg_stat_activity where state = 'idle';" ${DATABASE_NAME}
```

### Check the size of the connection pool
```shell
sudo -u postgres psql -c "select * from pg_settings where name = 'max_connections';"
```

### Check the log files for any errors related to connections or connection pool
```shell
sudo tail -f /var/log/postgresql/postgresql-main.log
```

## Repair

### Define variables
```shell
PG_CONFIG_FILE=${PATH_TO_POSTGRESQL_CONF}

NEW_CONNECTION_LIMIT=${NEW_CONNECTION_LIMIT}
```

### Check if PG_CONFIG_FILE exists and is writable
```shell
if [ ! -w "${PG_CONFIG_FILE}" ]; then

  echo "ERROR: ${PG_CONFIG_FILE} does not exist or is not writable."

  exit 1

fi
```

### Backup the PostgreSQL configuration file
```shell
cp "${PG_CONFIG_FILE}" "${PG_CONFIG_FILE}.bak"
```

### Update the connection limit in the configuration file
```shell
sed -i "s/^max_connections = .*/max_connections = ${NEW_CONNECTION_LIMIT}/" "${PG_CONFIG_FILE}"
```

### Restart PostgreSQL server to apply changes
```shell
systemctl restart postgresql
```

### Next Step
```shell
echo "Connection limit updated to ${NEW_CONNECTION_LIMIT}."
```

### Identify and terminate idle connections to free up resources for other connections.
```shell


#!/bin/bash



# Set variables

PG_USER=${YOUR_POSTGRES_USER}

PG_PASSWORD=${YOUR_POSTGRES_PASSWORD}

PG_DATABASE=${YOUR_POSTGRES_DATABASE}

PG_HOST=${YOUR_POSTGRES_HOST}

PG_PORT=${YOUR_POSTGRES_PORT}



# Get idle connections

IDLE_CONNECTIONS=$(psql -U $PG_USER -h $PG_HOST -p $PG_PORT $PG_DATABASE -c "SELECT pid, (now() - query_start) as duration, query FROM pg_stat_activity WHERE state = 'idle' AND now() - query_start > interval '5 minutes';")



# Loop through idle connections and kill them

while read -r row; do

    PID=$(echo "$row" | awk '{print $1}')

    psql -U $PG_USER -h $PG_HOST -p $PG_PORT $PG_DATABASE -c "SELECT pg_terminate_backend($PID);"

done <<< "$IDLE_CONNECTIONS"


```