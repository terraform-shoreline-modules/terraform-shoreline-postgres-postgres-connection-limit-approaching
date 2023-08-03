if [ ! -w "${PG_CONFIG_FILE}" ]; then

  echo "ERROR: ${PG_CONFIG_FILE} does not exist or is not writable."

  exit 1

fi