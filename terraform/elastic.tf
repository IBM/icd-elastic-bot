resource "ibm_database" "elastic" {
  name          = "elastic-bot"
  service       = "databases-for-elasticsearch"
  plan          = "platinum"
  version       = var.es_version
  location      = var.region
  adminpassword = var.es_password
  resource_group_id = ibm_resource_group.bot_resource_group.id

  group {
    group_id = "member"

    memory {
      allocation_mb = 15360
    }

    disk {
      allocation_mb = 102400
    }

    cpu {
      allocation_count = 3
    }
  }
}

data "ibm_database_connection" "es_connection" {
  endpoint_type = "public"
  deployment_id = ibm_database.elastic.id
  user_id       = var.es_username
  user_type     = "database"
}

# The data object below calls the ES URL in order to establish the full version of the deployed database
# because that is needed to deploy Kibana and Ent Search
# The full version gets stored in a local variable es-ful-version and then used in the codengine resources
data "http" "es_metadata" {
  url=  "https://${var.es_username}:${var.es_password}@${data.ibm_database_connection.es_connection.https[0].hosts[0].hostname}:${data.ibm_database_connection.es_connection.https[0].hosts[0].port}"
 insecure = true
}

locals {
    # get data from api call
    es_data = jsondecode(data.http.es_metadata.response_body)

    # get version
    es-full-version = local.es_data.version.number
}

output "es_url" {
  value     = "https://${var.es_username}:${ibm_database.elastic.adminpassword}@${data.ibm_database_connection.es_connection.https[0].hosts[0].hostname}:${data.ibm_database_connection.es_connection.https[0].hosts[0].port}"
  sensitive = true
}
