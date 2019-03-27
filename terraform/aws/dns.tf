#--------------------------------------------------------
#--Create private DNS entries
#--------------------------------------------------------
resource "aws_route53_zone" "private" {
  name = "${local.config["domain"]}"

  vpc {
    vpc_id = "${aws_vpc.eleksintegration.id}"
  }

  tags {
      Name = "${local.config["domain"]} private zone"
      Terraform = "true"
      Environment = "${local.env}"
  }
}
#--------------------------------------------------------
#--Register Bastion node
#--------------------------------------------------------
resource "aws_route53_record" "bastion" {
  count   = "${local.config["bastion_enabled"] ? 1 : 0}"

  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "${local.env}-bastion"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion.private_ip}"]

  depends_on = ["aws_instance.bastion"]
}
#--------------------------------------------------------
#--Register Master nodes
#--------------------------------------------------------
resource "aws_route53_record" "master" {
  count   = "${local.config["k8s_master_count"]}"

  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "${local.env}-master-0${count.index+1}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.master.*.private_ip, count.index)}"]

  depends_on = ["aws_instance.master"]
}
#--------------------------------------------------------
#--Register Master nodes
#--------------------------------------------------------
resource "aws_route53_record" "worker" {
  count   = "${local.config["k8s_worker_count"]}"

  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "${local.env}-worker-0${count.index+1}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.worker.*.private_ip, count.index)}"]

  depends_on = ["aws_instance.worker"]
}
