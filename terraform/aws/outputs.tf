#--------------------------------------------------------
#--Output Section
#--------------------------------------------------------
output "ec2_ami_id" {
  value = "${data.aws_ami.centos_ami.image_id}"
}
output "bastion_public_ip" {
  value = "${aws_instance.bastion.*.public_ip}"
}
output "alb_dns" {
  value = "Login Kubernetes Dashboard: ${aws_lb.frontend.dns_name}"
}
output "show_bastion_dns" {
  value = "${aws_route53_record.bastion.0.fqdn}"
}

