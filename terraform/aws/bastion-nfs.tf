#----------------------------------------------------------------------------
#-- Install NFS server on bastion host and populate it with persistent dir
#-- this will be mount to dockers for auto-initialization
#----------------------------------------------------------------------------

# zip 
data "archive_file" "persistent-zip" {
  type        = "zip"
  source_dir  = "${local.root}/persistent"
  output_path = "${local.work}/persistent.zip"
}

resource "null_resource" "bastion-nfs" {
  connection {
    type        = "ssh"
    host        = "${aws_instance.bastion.public_ip}"
    user        = "${local.config["username"]}"
    private_key = "${file("${local.config["key_path_local"]}${local.config["key_name"]}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y -q install nfs-utils unzip && sudo systemctl enable nfs-server.service && sudo systemctl start nfs-server.service",
      "sudo chmod 646 /etc/exports",
      "sudo mkdir /var/nfs",
      "sudo chown centos:adm /var/nfs", # WAS: nfsnobody:nfsnobody NOTE: current user must have privelegies to write this folder to use file provisionef simpler!
      "sudo chmod 775 /var/nfs",
      "sudo echo '/var/nfs        *(rw,sync,no_subtree_check)' >> /etc/exports",
      "sudo exportfs -a"
    ]
  }
    
  depends_on = ["aws_instance.bastion"]
}

# process template to write 00-cloud.yaml
# it required inside docker containers to do correct ititialization
data "template_file" "00-cloud-yaml" {
  template = "${file("${local.root}/persistent/.cloud/00-cloud.yaml.tft")}"
  vars {
    public_host_name  = "${aws_lb.frontend.dns_name}"
    domain            = "default.svc.cluster.local"
    component_ports   = "${jsonencode(local.component_ports)}"
    component_hosts   = "${jsonencode(data.null_data_source.component_hosts.outputs)}"
  }
}
## re-create persistent storage
resource "null_resource" "persistent" {
  connection {
    type        = "ssh"
    host        = "${aws_instance.bastion.public_ip}"
    user        = "${local.config["username"]}"
    private_key = "${file("${local.config["key_path_local"]}${local.config["key_name"]}")}"
  }

  provisioner "file" "persistent-zip" {
    source        = "${local.work}/persistent.zip"
    destination   = "/home/${local.config["username"]}/persistent.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /var/nfs/persistent",
      "unzip /home/${local.config["username"]}/persistent.zip -d /var/nfs/persistent",
      "rm -f /home/${local.config["username"]}/persistent.zip",
      "find /var/nfs/persistent -name *.tft -delete"
    ]
  }

  #write previously prepared template to a remote file
  provisioner "file" "00-cloud-yaml" {
    content     = "${data.template_file.00-cloud-yaml.rendered}"
    destination = "/var/nfs/persistent/.cloud/00-cloud.yaml"
  }
  depends_on = ["null_resource.bastion-nfs"]
}
