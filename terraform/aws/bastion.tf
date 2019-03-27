#--------------------------------------------------------
#--Bastion host
#--------------------------------------------------------
resource "aws_instance" "bastion" {
  count                  = "${local.config["bastion_enabled"] ? 1 : 0}"

  availability_zone      = "${data.aws_availability_zones.available.names["0"]}"
  ami                    = "${data.aws_ami.centos_ami.image_id}"
  instance_type          = "${local.config["bastion_flavor"]}"
  key_name               = "${local.config["key_name"]}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  subnet_id              = "${aws_subnet.public.0.id}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = true
  }
  
  tags {
    Name                = "${local.env}-bastion"
    Terraform           = "true"
    Environment         = "${local.env}"
  }
  depends_on = ["aws_instance.master","aws_instance.worker"]
}