## define bpm master component

module "api" {
  source    = "github.com/eleks/terraform-kubernetes-demo/kub-component-java-base"

  name      = "api"
  namespace = "default"
  image     = "eleks/base-wso2am-2.6.0"
  replicas  = 1
  //command   = ""

  mem_min   = "1Gi"
  mem_max   = "2Gi"
  cpu_min   = "0.5"
  cpu_max   = "1"
  ports     = "${local.component_ports["api"]}"
  ## wait for kubernetes and persistent ready
  depends_on = ["${module.kub.ready}", "${module.persistent.ready}"]
}

# api management ports
module "port-api-mhttps" {
  source          = "github.com/eleks/terraform-kubernetes-demo/aws-listener"
  port            = "mhttps"
  ports           = "${local.component_ports["api"]}"
  params          = "${ module.kub.default_port_params }"
}

module "port-api-mhttp" {
  source          = "github.com/eleks/terraform-kubernetes-demo/aws-listener"
  port            = "mhttp"
  ports           = "${local.component_ports["api"]}"
  params          = "${ module.kub.default_port_params }"
}

# api worker ports
module "port-api-https" {
  source          = "github.com/eleks/terraform-kubernetes-demo/aws-listener"
  port            = "https"
  ports           = "${local.component_ports["api"]}"
  params          = "${ module.kub.default_port_params }"
}

module "port-api-http" {
  source          = "github.com/eleks/terraform-kubernetes-demo/aws-listener"
  port            = "http"
  ports           = "${local.component_ports["api"]}"
  params          = "${ module.kub.default_port_params }"
}

output "component-api" {
  value = "${module.port-api-mhttps.public_protocol}://${data.null_data_source.component_hosts.outputs["api"]}:${module.port-api-mhttps.public_port}"
}

