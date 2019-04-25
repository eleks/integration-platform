## API manager analytiX Worker definition 
## To collect statistics about api manager

module "apxw" {
  source    = "github.com/eleks/terraform-kubernetes-demo/kub-component-java-base"

  name      = "apxw"
  namespace = "default"
  image     = "eleks/base-wso2am-analytics-2.6.0"
  replicas  = 1
  command   = "worker.sh"

  mem_min   = "1Gi"
  mem_max   = "2Gi"
  cpu_min   = "0.5"
  cpu_max   = "1"
  ports     = "${local.component_ports["apxw"]}"
  ## wait for kubernetes and persistent ready
  depends_on = ["${module.kub.ready}", "${module.persistent.ready}"]
}
