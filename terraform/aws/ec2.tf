#--------------------------------------------------------
#--Create EC2 instances
#--------------------------------------------------------
#--Masters
#--------------------------------------------------------
resource "aws_instance" "master" {
  count                  = "${local.config["k8s_master_count"]}"

  availability_zone      = "${data.aws_availability_zones.available.names[count.index]}"
  ami                    = "${data.aws_ami.centos_ami.image_id}"
  instance_type          = "${local.config["master_flavor"]}"
  key_name               = "${local.config["key_name"]}"
  vpc_security_group_ids = ["${aws_security_group.master.id}"]
  subnet_id              = "${aws_subnet.private.0.id}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "80"
    delete_on_termination = true
  }

  tags {
    Name                = "${local.env}-master-0${count.index+1}"
    Terraform           = "true"
    Environment         = "${local.env}"
  }
}
#--------------------------------------------------------
#--Workers
#--------------------------------------------------------
resource "aws_instance" "worker" {
  count                  = "${local.config["k8s_worker_count"]}"

  availability_zone      = "${data.aws_availability_zones.available.names[count.index]}"
  ami                    = "${data.aws_ami.centos_ami.image_id}"
  instance_type          = "${local.config["worker_flavor"]}"
  key_name               = "${local.config["key_name"]}"
  vpc_security_group_ids = ["${aws_security_group.worker.id}"]
  subnet_id              = "${element(aws_subnet.private.*.id, count.index)}"
//  iam_instance_profile   = "${aws_iam_instance_profile.workers.name}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "80"
    delete_on_termination = true
  }

  tags {
    Name                = "${local.env}-worker-0${count.index+1}"
    Terraform           = "true"
    Environment         = "${local.env}"
  }
}
