# create kubernetes cluster

# init demo certificates
module "default-certs" {
  source = "github.com/eleks/terraform-kubernetes-demo/certificates"
}

module "kub" {
  source    = "github.com/eleks/terraform-kubernetes-demo/aws-kub"

  kubeapi_token    = "${var.kubeapi_token}"
  cluster_name     = "${terraform.workspace}"
  k8s_worker_count = 2

  certificate_key  = "${module.default-certs.key}"
  certificate_body = "${module.default-certs.crt}"

  image_filter_name = "CentOS Linux 7 x86_64 HVM EBS ENA 1805*" #"CentOS 7.5 Base Image"

  bastion_post_init=[
    ## "sudo yum install -y -q ..."
  ]
}

output "bastion-ip" {
  value = "${module.kub.bastion-ip}"
}

output "kub-dashboard" {
  value = "${module.kub.dashboard}"
}

output "kub-token" {
  value = "${module.kub.kubeapi_token}"
}

