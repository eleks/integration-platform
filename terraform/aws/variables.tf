#--------------------------------------------------------
#--General variables section
#--------------------------------------------------------
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "deployer_token" {}


locals {
  root      = "${path.root}/../.."
  work      = "./.terraform/temp"

  configs = {
      defaults = {
          # General configuration
          aws_region         = "us-west-1"
          aws_az_count       = 2
          aws_cidr           = "172.16.0.0/16"
          eleks_lviv_cidr    = "193.105.219.210/32"
          flannel_cidr       = "10.244.0.0/16"
          key_name           = "deployer-key"
          key_path_local     = "${local.root}/.ssh/"
          key_path_remote    = "~/.ssh/"
          username           = "centos"
          s3_bucket          = "eleks-configurations"
          ssl_cert_name      = "demo_ssl_cert"
      }

      dev = {
          # Development environment
          domain                = "eleksintegration.com"
          k8s_master_count      = 1
          k8s_worker_count      = 2
          master_flavor         = "t2.medium"
          worker_flavor         = "t2.medium"
          bastion_enabled       = true
          bastion_flavor        = "t2.micro"
      }
  }

  config    = "${merge(local.configs["defaults"], local.configs[terraform.workspace])}"
  env       = "${terraform.workspace}"
}