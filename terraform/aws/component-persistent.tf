# deploy artifacts through default persistent storage
module "persistent" {
  source    = "github.com/eleks/terraform-kubernetes-demo/persistent-nfs"
  ssh_host = "${module.kub.bastion-ip}"
  persistent_local = "../../persistent"
  templates=[
    ".cloud/00-cloud.yaml"
  ]
  vars = {
    public_host_name  = "${module.kub.hostname}"
    domain            = "default.svc.cluster.local"
    component_ports   = "${jsonencode(local.component_ports)}"
    component_hosts   = "${jsonencode(data.null_data_source.component_hosts.outputs)}"
    workspace         = "${terraform.workspace}"
  }
  depends_on = ["${module.kub.ready}"]
}
