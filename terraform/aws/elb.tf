#--------------------------------------------------------
#--Create Application LoadBalancer
#--------------------------------------------------------

locals {
  # collect all below results into a map to expose ports later
  default_expose_port_params = {
    vpc_id          = "${aws_vpc.eleksintegration.id}"
    certificate_arn = "${aws_iam_server_certificate.eleksintegration.arn}"
    public_arn      = "${aws_lb.frontend.arn}"
    target_id       = "${aws_instance.master.0.private_ip}"
  }
}

#--------------------------------------------------------
#--Creating self-signed certificates
#--------------------------------------------------------
resource "aws_iam_server_certificate" "eleksintegration" {
  name             = "${local.config["ssl_cert_name"]}"
  certificate_body = "${file("${local.root}/certificates/web-crt.pem")}"
  private_key      = "${file("${local.root}/certificates/web-key.pem")}"
  lifecycle {
    ignore_changes = [
      # somehow following tags in state differ from specified in the input///
      "id", "certificate_body", "certificate_chain"
    ]
  }
}

#--------------------------------------------------------
#--Create Application LoadBalancer
#--------------------------------------------------------
resource "aws_lb" "frontend" {
  name               = "${local.env}-alb"

  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.lb.id}"]
  subnets                    = ["${aws_subnet.public.*.id}"]

  tags {
    Name = "${local.env} Application LoadBalancer"
    Terraform = "true"
    Environment = "${local.env}"
  }
}
#--------------------------------------------------------
#--Redirect HTTP to HTTPS
#--------------------------------------------------------
resource "aws_lb_listener" "frontend_80" {
  load_balancer_arn = "${aws_lb.frontend.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
#--------------------------------------------------------
#--HTTPS listener default 443 listener
#--------------------------------------------------------
resource "aws_lb_listener" "frontend_443" {
  load_balancer_arn = "${aws_lb.frontend.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
  certificate_arn   = "${aws_iam_server_certificate.eleksintegration.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend.arn}"
  }

}
#--------------------------------------------------------
#--HTTPS listener default 6443 kube-api listener
#--------------------------------------------------------
resource "aws_lb_listener" "frontend_6443" {
  load_balancer_arn = "${aws_lb.frontend.arn}"
  port              = "6443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
  certificate_arn   = "${aws_iam_server_certificate.eleksintegration.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.kubeapi.arn}"
  }

}
#--------------------------------------------------------
# Link SSL certificate to the HTTPS listener on 443 port 
#--------------------------------------------------------
resource "aws_lb_listener_certificate" "front_end_443" {
  listener_arn    = "${aws_lb_listener.frontend_443.arn}"
  certificate_arn = "${aws_iam_server_certificate.eleksintegration.arn}"
}
#--------------------------------------------------------
# Create Target group for LoadBalancer
#--------------------------------------------------------
resource "aws_lb_target_group" "backend" {
  name = "${local.env}-backend-target-group"

  deregistration_delay = 30
  port                 = "30080"
  protocol             = "HTTPS"
  slow_start           = 30
  target_type          = "ip"
  vpc_id               = "${aws_vpc.eleksintegration.id}"

  health_check {
    healthy_threshold   = 3
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags {
    Name = "${local.env} ALB backend target group"
    Environment = "${local.env}"
  }
}
resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn  = "${aws_lb_target_group.backend.arn}"
  target_id         = "${aws_instance.master.0.private_ip}"
  depends_on        = ["aws_instance.master"]
}
#--------------------------------------------------------
# Create Target group for kube-apiserver
#--------------------------------------------------------
resource "aws_lb_target_group" "kubeapi" {
  name = "${local.env}-kubeapi-target-group"

  deregistration_delay = 30
  port                 = "6443"
  protocol             = "HTTPS"
  slow_start           = 30
  target_type          = "ip"
  vpc_id               = "${aws_vpc.eleksintegration.id}"

  health_check {
    healthy_threshold   = 3
    matcher             = "200"
    path                = "/"
    protocol            = "HTTPS"
    timeout             = 5
    unhealthy_threshold = 3
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags {
    Name = "${local.env} ALB kube-apiserver 6443 target group"
    Environment = "${local.env}"
  }
}
resource "aws_lb_target_group_attachment" "kubeapi" {
  target_group_arn  = "${aws_lb_target_group.kubeapi.arn}"
  target_id         = "${aws_instance.master.0.private_ip}"
  depends_on        = ["aws_instance.master"]
}
