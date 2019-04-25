#--------------------------------------------------------

terraform {
    required_version = "> 0.11.0"
}
#--------------------------------------------------------
provider "aws" {
  # version = "~> 2.6"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

provider "kubernetes" {
  host  = "https://${module.kub.hostname}:6443"
  token = "${module.kub.kubeapi_token}"
}

#  "random" (2.1.1)...
#  "local" (1.2.1)...
#  "template" (2.1.1)...
#  "kubernetes" (1.6.2)...
#  "null" (2.1.1)...
#  "archive" (1.2.1)...
#  "aws" (2.7.0)...
