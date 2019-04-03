#----------------------------------------------------------------------------
#-- kubernetes provision with ansible
#----------------------------------------------------------------------------
# TODO: split kub-init and kub-(re)start

# process template to generate datacenter_env
data "template_file" "datacenter_env" {
  template = "${file("${local.root}/provision/inventory/datacenter_env.tft")}"
  vars {
    local_env    = "${local.env}"
    worker_count = "${local.config["k8s_worker_count"]}"
  }
}
# process template to generate datacenter_env
data "archive_file" "provision-zip" {
  type        = "zip"
  source_dir  = "${local.root}/provision"
  output_path = "${local.work}/provision.zip"
}

#----------------------------------------------------------------------------
#--Prepare ansible for provision
#----------------------------------------------------------------------------
resource "null_resource" "k8s-init-master" {
  connection {
    type        = "ssh"
    host        = "${aws_instance.bastion.public_ip}"
    user        = "${local.config["username"]}"
    private_key = "${file("${local.config["key_path_local"]}${local.config["key_name"]}")}"
  }

  provisioner "file" {
    source        = "${local.config["key_path_local"]}${local.config["key_name"]}"
    destination   = "${local.config["key_path_remote"]}${local.config["key_name"]}"
  }

  provisioner "file" {
    source        = "${local.work}/provision.zip"
    destination   = "/home/${local.config["username"]}/provision.zip"
  }

  provisioner "remote-exec" "init" {
    inline = [
      "set -e",
      "sudo hostnamectl set-hostname --static ${local.env}-bastion",
      "sudo yum update -y -q && sudo yum install -y -q epel-release && sudo yum install -y python-pip unzip",
      "chmod 700 ${local.config["key_path_remote"]}${local.config["key_name"]}",
      "sudo pip install ansible",
      "rm -rf /home/${local.config["username"]}/provision",
      "unzip /home/${local.config["username"]}/provision.zip -d /home/${local.config["username"]}/provision",
      "rm -f /home/${local.config["username"]}/provision.zip",
      "find /home/${local.config["username"]}/provision -name *.tft -delete"
    ]
  }

  #write previously prepared template to a remote file
  provisioner "file" "datacenter_env" {
    content     = "${data.template_file.datacenter_env.rendered}"
    destination = "/home/${local.config["username"]}/provision/inventory/datacenter_env"
  }

  provisioner "remote-exec" "k8s-init-master" {
    inline = [
      "cd provision && ansible-playbook deploy-kubernetes.yml -vvv --extra-vars '{\"local_env\":\"${local.env}\", \"deployer_token\":\"${var.deployer_token}\", \"elb_dns\":\"${aws_lb.frontend.dns_name}\", \"bastion_fqdn\":\"${aws_route53_record.bastion.fqdn}\"}' --private-key ${local.config["key_path_remote"]}${local.config["key_name"]}"
    ]
  }
  depends_on = ["aws_instance.bastion", "null_resource.bastion-nfs"]
}

/*
resource "null_resource" "k8s-init-worker" {
  ## count = "${ length(aws_instance.worker.*.id) }"
  count = "${local.config["k8s_worker_count"]}"
  connection {
    type        = "ssh"
    host        = "${aws_instance.bastion.public_ip}"
    user        = "${local.config["username"]}"
    private_key = "${file("${local.config["key_path_local"]}${local.config["key_name"]}")}"
  }
  provisioner "remote-exec" "k8s-init-worker" {
    inline = [
      "cd provision && ansible-playbook deploy-kubernetes.yml -v -i '${local.env}-worker-0${count.index+1},' --extra-vars '{\"local_env\":\"${local.env}\", \"deployer_token\":\"${var.deployer_token}\", \"elb_dns\":\"${aws_lb.frontend.dns_name}\", \"bastion_fqdn\":\"${aws_route53_record.bastion.fqdn}\"}' --private-key ${local.config["key_path_remote"]}${local.config["key_name"]}"
    ]
  }
  depends_on = ["null_resource.k8s-init-master"]
}
*/
