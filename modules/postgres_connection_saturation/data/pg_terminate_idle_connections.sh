

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