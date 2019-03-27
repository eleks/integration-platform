## define api master component

module "api" {
  source    = "../component-wso2"

  name      = "api"
  namespace = "default"
  image     = "eleks/base-wso2am-2.6.0"
  replicas  = 1
  #command   = ...

  mem_min   = "1Gi"
  mem_max   = "2Gi"
  cpu_min   = "0.5"
  cpu_max   = "1"
  ports     = "${local.component_ports["api"]}"
  ## wait for bastion initialization
  depends_on = ["${kubernetes_persistent_volume_claim.nfs-claim.metadata.0.uid}"]
}

## expose public ports
## TODO: waiting for_each (v0.12) to put this definition in loop

module "port-api-mhttps" {
  source          = "../aws-elb-https"
  name            = "api"
  port            = "mhttps"
  ports           = "${local.component_ports["api"]}"
  params          = "${local.default_expose_port_params}"
  ## wait for bastion initialization
  #depends_on = ["${kubernetes_persistent_volume_claim.nfs-claim.metadata.0.uid}"]
}

module "port-api-mhttp" {
  source          = "../aws-elb-http"
  name            = "api"
  port            = "mhttp"
  ports           = "${local.component_ports["api"]}"
  params          = "${local.default_expose_port_params}"
  ## wait for bastion initialization
  #depends_on = ["${kubernetes_persistent_volume_claim.nfs-claim.metadata.0.uid}"]
}


module "port-api-https" {
  source          = "../aws-elb-https"
  name            = "api"
  port            = "https"
  ports           = "${local.component_ports["api"]}"
  params          = "${local.default_expose_port_params}"
  ## wait for bastion initialization
  #depends_on = ["${kubernetes_persistent_volume_claim.nfs-claim.metadata.0.uid}"]
}

module "port-api-http" {
  source          = "../aws-elb-http"
  name            = "api"
  port            = "http"
  ports           = "${local.component_ports["api"]}"
  params          = "${local.default_expose_port_params}"
  ## wait for bastion initialization
  #depends_on = ["${kubernetes_persistent_volume_claim.nfs-claim.metadata.0.uid}"]
}


output "component-api" {
  value = "https://${data.null_data_source.component_hosts.outputs["api"]}:${module.port-api-mhttps.public_port}"
}

