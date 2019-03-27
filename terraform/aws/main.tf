#--------------------------------------------------------
#  Project:          Integration Platform as a Code
#  Author:           Oleksandr Ridkodub
#  Email:            oleksandr.ridkodub@eleks.com
#  Date created:     24.01.2019
#--------------------------------------------------------

terraform {
    required_version = "> 0.11.0"
}
#--------------------------------------------------------
#--Provider Section
#--------------------------------------------------------

provider "aws" {
  version = "~> 1.56"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${local.config["aws_region"]}"
}

provider "archive" {}
provider "local" {}
provider "template" {}
