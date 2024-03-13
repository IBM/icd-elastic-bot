resource "ibm_database" "elastic" {
  name          = "elastic-bot"
  service       = "databases-for-elasticsearch"
  plan          = "platinum"
  version       = var.es_version
  location      = var.region
  adminpassword = var.es_password
  resource_group_id = ibm_resource_group.bot_resource_group.id
}

data "ibm_database_connection" "es_connection" {
  endpoint_type = "public"
  deployment_id = ibm_database.elastic.id
  user_id       = var.es_username
  user_type     = "database"
}

output "es_url" {
  value     = "https://${var.es_username}:${ibm_database.elastic.adminpassword}@${data.ibm_database_connection.es_connection.https[0].hosts[0].hostname}:${data.ibm_database_connection.es_connection.https[0].hosts[0].port}"
  sensitive = true
}
