resource "ibm_iam_service_id" "serviceID" {
  name        = "trucktrackerSID"
  description = "The service id that Code Engine will use to access Container Registry"
}

resource "ibm_iam_service_policy" "botPolicy" {
  iam_service_id = ibm_iam_service_id.serviceID.id
  roles          = ["Writer"]


  resources {
    region = "eu-gb"
    service = "container-registry"
  }
}

resource "ibm_iam_service_api_key" "botApiKey" {
  name = "botkey"
  iam_service_id = ibm_iam_service_id.serviceID.iam_id
}