#-------------------------------------------------------------
#--K8S Bastion SG
#-------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name        = "${local.env}-bastion-sg"
  description = "Security rules for bastion node"
  vpc_id      = "${aws_vpc.eleksintegration.id}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${local.env} bastion SG"
    Terraform   = "true"
    Environment = "${local.env}"
  }
}
resource "aws_security_group_rule" "bastion_from_world" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "bastion_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id = "${aws_security_group.bastion.id}"
  source_security_group_id = "${aws_security_group.master.id}"
}
resource "aws_security_group_rule" "bastion_from_worker" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id = "${aws_security_group.bastion.id}"
  source_security_group_id = "${aws_security_group.worker.id}"
}
#-------------------------------------------------------------
#--K8S Masters SG
#-------------------------------------------------------------
resource "aws_security_group" "master" {
  name        = "${local.env}-master-sg"
  description = "Security rules for master nodes"
  vpc_id      = "${aws_vpc.eleksintegration.id}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${local.env} masters SG"
    Terraform   = "true"
    Environment = "${local.env}"
  }
}
resource "aws_security_group_rule" "master_workers" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.worker.id}"
  security_group_id        = "${aws_security_group.master.id}"
}
resource "aws_security_group_rule" "master_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.master.id}"
}
resource "aws_security_group_rule" "master_bastion_all" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.master.id}"
}
resource "aws_security_group_rule" "master_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.lb.id}"
  security_group_id        = "${aws_security_group.master.id}"
}
#-------------------------------------------------------------
#--K8S Workers SG
#-------------------------------------------------------------
resource "aws_security_group" "worker" {
  name        = "${local.env}-worker-sg"
  description = "Security rules for worker nodes"
  vpc_id      = "${aws_vpc.eleksintegration.id}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${local.env} workers SG"
    Terraform   = "true"
    Environment = "${local.env}"
  }
}
resource "aws_security_group_rule" "worker_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.master.id}"
  security_group_id        = "${aws_security_group.worker.id}"
}
resource "aws_security_group_rule" "worker_bastion_icmp" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.worker.id}"
}
resource "aws_security_group_rule" "worker_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.worker.id}"
}
resource "aws_security_group_rule" "worker_themselves" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.worker.id}"
  security_group_id        = "${aws_security_group.worker.id}"
}
#-------------------------------------------------------------
#--Security group for Application LoadBalancer
#-------------------------------------------------------------
resource "aws_security_group" "lb" {
  name        = "${local.env}-alb-security-group"
  description = "controls access to the ALB"
  vpc_id      = "${aws_vpc.eleksintegration.id}"

  # Allow all HTTP connections from the internet
  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  /*
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 9443
    to_port     = 9443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 8280
    to_port     = 8280
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 8243
    to_port     = 8243
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }
  */
  # Allow all outgoing connections
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${local.env} ALB security group"
    Terraform = "true"
    Environment = "${local.env}"
  }
}