# this script has to run at the end, when everything else is deployed
# so will make it depend on the last part of the sequence, which is the codeengine.tf null script

resource "null_resource" "post_deployment" {
  triggers = {
    always_run             = "${timestamp()}" #this ensures that the script always runs to re-instante the below env variables 
    es_url = "https://${var.es_username}:${ibm_database.elastic.adminpassword}@${data.ibm_database_connection.es_connection.https[0].hosts[0].hostname}:${data.ibm_database_connection.es_connection.https[0].hosts[0].port}"
  }

  provisioner "local-exec" {
    command = <<EOF
      curl -kX PUT -H 'Content-Type: application/json' -d' {"input": {"field_names": ["text_field"]}}' "${self.triggers.es_url}/_ml/trained_models/.elser_model_1?pretty&wait_for_completion=true"
      curl -kX POST "${self.triggers.es_url}/_ml/trained_models/.elser_model_1/deployment/_start?deployment_id=for_search"
    EOF

  }
  depends_on = [
    null_resource.kibana_app_update
  ]
}


