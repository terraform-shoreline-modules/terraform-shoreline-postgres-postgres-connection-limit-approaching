resource "shoreline_notebook" "postgres_connection_saturation" {
  name       = "postgres_connection_saturation"
  data       = file("${path.module}/data/postgres_connection_saturation.json")
  depends_on = [shoreline_action.invoke_config_change,shoreline_action.invoke_check_pg_config_file,shoreline_action.invoke_pg_terminate_idle_connections]
}

resource "shoreline_file" "config_change" {
  name             = "config_change"
  input_file       = "${path.module}/data/config_change.sh"
  md5              = filemd5("${path.module}/data/config_change.sh")
  description      = "Define variables"
  destination_path = "/agent/scripts/config_change.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "check_pg_config_file" {
  name             = "check_pg_config_file"
  input_file       = "${path.module}/data/check_pg_config_file.sh"
  md5              = filemd5("${path.module}/data/check_pg_config_file.sh")
  description      = "Check if PG_CONFIG_FILE exists and is writable"
  destination_path = "/agent/scripts/check_pg_config_file.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "pg_terminate_idle_connections" {
  name             = "pg_terminate_idle_connections"
  input_file       = "${path.module}/data/pg_terminate_idle_connections.sh"
  md5              = filemd5("${path.module}/data/pg_terminate_idle_connections.sh")
  description      = "Identify and terminate idle connections to free up resources for other connections."
  destination_path = "/agent/scripts/pg_terminate_idle_connections.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_config_change" {
  name        = "invoke_config_change"
  description = "Define variables"
  command     = "`chmod +x /agent/scripts/config_change.sh && /agent/scripts/config_change.sh`"
  params      = ["NEW_CONNECTION_LIMIT","PATH_TO_POSTGRESQL_CONF"]
  file_deps   = ["config_change"]
  enabled     = true
  depends_on  = [shoreline_file.config_change]
}

resource "shoreline_action" "invoke_check_pg_config_file" {
  name        = "invoke_check_pg_config_file"
  description = "Check if PG_CONFIG_FILE exists and is writable"
  command     = "`chmod +x /agent/scripts/check_pg_config_file.sh && /agent/scripts/check_pg_config_file.sh`"
  params      = []
  file_deps   = ["check_pg_config_file"]
  enabled     = true
  depends_on  = [shoreline_file.check_pg_config_file]
}

resource "shoreline_action" "invoke_pg_terminate_idle_connections" {
  name        = "invoke_pg_terminate_idle_connections"
  description = "Identify and terminate idle connections to free up resources for other connections."
  command     = "`chmod +x /agent/scripts/pg_terminate_idle_connections.sh && /agent/scripts/pg_terminate_idle_connections.sh`"
  params      = []
  file_deps   = ["pg_terminate_idle_connections"]
  enabled     = true
  depends_on  = [shoreline_file.pg_terminate_idle_connections]
}

