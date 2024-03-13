variable "ibmcloud_api_key" {}
variable "region" {}
variable "es_username" {}
variable "es_password" {}
variable "es_version" {}
variable "es_minor_version" {
    default = "1"
}
variable "elastic_index" {
    default = "search-bot"
}
variable "wx_project_id" {}
variable "ibmcloud_watsonx_api_key" {}