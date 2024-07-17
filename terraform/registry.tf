resource "ibm_cr_namespace" "elastic-bot" {
  name              = "elasticbot"
  resource_group_id = ibm_resource_group.bot_resource_group.id
}


resource "null_resource" "pythonApp" {
  triggers = {
    ibmcloud_api_key = var.ibmcloud_api_key
    region           = var.region
    resource_group   = ibm_resource_group.bot_resource_group.id
    cr_namespace     = ibm_cr_namespace.elastic-bot.id
  }

  provisioner "local-exec" {
    # build the app docker image and push it to the image registry
    command = <<EOF
      cd ../python-app
      docker build --platform="linux/amd64" -t elasticbot-pythonapp .
      docker tag elasticbot-pythonapp uk.icr.io/${self.triggers.cr_namespace}/pythonapp:latest
      ibmcloud login -r ${self.triggers.region} -g ${self.triggers.resource_group} --apikey ${self.triggers.ibmcloud_api_key}
      ibmcloud plugin install cr
      ibmcloud cr region-set eu-gb
      ibmcloud cr login
      docker push uk.icr.io/elasticbot/pythonapp:latest
    EOF

  }
}

output "cr_id" {
  value = ibm_cr_namespace.elastic-bot.id
}