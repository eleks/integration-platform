# define external port on public loadbalancer

variable "params" {
  # parameters required for specific port.
  type = "map"
}
variable "ports" {
  # ports in component-roles format
  type = "map"
}
variable "name"  {}
variable "port"  {} # port name from ports map 
# variable to implement depends-on values. not used inside module...
variable "depends_on"{ default = [], type = "list"}

locals {
  port_list = "${ split( " ", var.ports[var.port] ) }"
  public_port = "${local.port_list[2]}"
  target_port = "${local.port_list[1]}"
}
output "public_port" {
  value = "${local.public_port}"
}
output "target_port" {
  value = "${local.target_port}"
}

#--------------------------------------------------------
#--HTTP listener 
#--------------------------------------------------------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${var.params["public_arn"]}"
  port              = "${ local.public_port }"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
  #certificate_arn   = "${var.params["certificate_arn"]}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target.arn}"
  }
}

#--------------------------------------------------------
# Create Target group
#--------------------------------------------------------
resource "aws_lb_target_group" "target" {
  name = "${var.name}-${local.public_port}-to-${local.target_port}"

  deregistration_delay = 30
  port                 = "${ local.target_port }"
  protocol             = "HTTP"
  slow_start           = 30
  target_type          = "ip"
  vpc_id               = "${ var.params["vpc_id"] }"

  health_check {
    healthy_threshold   = 3
    matcher             = "200-399"
    path                = ""
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags {
    env = "${terraform.workspace}"
  }
}
#---------------------------------------------------------
resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn  = "${aws_lb_target_group.target.arn}"
  target_id         = "${ var.params["target_id"] }"
  #depends_on        = ["aws_instance.master"]
}
