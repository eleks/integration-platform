#----------------------------------------------------------------------------
#-- declare connection to kube
#----------------------------------------------------------------------------

output "component-k8s"{
  value = "https://${aws_lb.frontend.dns_name}"
}

provider "kubernetes" {
  host  = "https://${aws_lb.frontend.dns_name}:6443"
  token = "${var.deployer_token}"
}

#----------------------------------------------------------------------------
#-- declare persistent storage in the kubicus vulgaris :)
#----------------------------------------------------------------------------
resource "kubernetes_persistent_volume" "nfs-volume" {
  metadata {
    name = "nfs-volume"
    #annotations {
    #  bastion_id = "${null_resource.bastion-init.id}"
    #}
  }
  spec {
    capacity {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        server = "${aws_route53_record.bastion.fqdn}"
        path   = "/var/nfs/persistent"
      }
    }
  }
  depends_on = ["null_resource.bastion-init"]
}
resource "kubernetes_persistent_volume_claim" "nfs-claim" {
  metadata {
    name = "nfs-claim"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "2Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.nfs-volume.metadata.0.name}"
  }
}

