## define api master component

module "apxw" {
  source    = "../component-wso2"

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
  ## wait for bastion initialization
  depends_on = ["${kubernetes_persistent_volume_claim.nfs-claim.metadata.0.uid}"]
}

