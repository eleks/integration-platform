#--------------------------------------------------------
#--Create new VPC with Private and Public Subnets
#--------------------------------------------------------
resource "aws_vpc" "eleksintegration" {
  cidr_block = "${local.config["aws_cidr"]}"

  assign_generated_ipv6_cidr_block = false
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags {
    Name = "${local.env} EleksIntegration VPC"
    Terraform = "true"
    Environment = "${local.env}"
  }
}
#--------------------------------------------------------
#--Customize dhcp to use short domain names
#--------------------------------------------------------
resource "aws_vpc_dhcp_options" "domain_suffix" {
  domain_name          = "${local.config["domain"]}"
  domain_name_servers  = ["AmazonProvidedDNS"]


  tags = {
        Name                = "${local.env} dhcp custom settings for ${local.config["domain"]}"
        Terraform           = "true"
        Environment         = "${local.env}"
  }
}
resource "aws_vpc_dhcp_options_association" "domain_suffix_assoc" {
    vpc_id = "${aws_vpc.eleksintegration.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.domain_suffix.id}"
}
#--------------------------------------------------------
#--Create public subnets for each AZ
#--------------------------------------------------------
resource "aws_subnet" "public" {
    count                   = "${local.config["aws_az_count"]}"

    availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
    cidr_block              = "${cidrsubnet(aws_vpc.eleksintegration.cidr_block, 8, count.index)}"
    map_public_ip_on_launch = true
    vpc_id                  = "${aws_vpc.eleksintegration.id}"

    tags {
        AvailabilityZone    = "${data.aws_availability_zones.available.names[count.index]}"
        Name                = "${local.env} public subnet ${count.index}"
        Terraform           = "true"
        Environment         = "${local.env}"
    }
}
#--------------------------------------------------------
#--Create private subnets for each AZ
#--------------------------------------------------------
resource "aws_subnet" "private" {
  count                   = "${local.config["aws_az_count"]}"

  assign_ipv6_address_on_creation = false
  availability_zone               = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block                      = "${cidrsubnet(aws_vpc.eleksintegration.cidr_block, 8, 10 + count.index)}"
  map_public_ip_on_launch         = false
  vpc_id                          = "${aws_vpc.eleksintegration.id}"

  tags {
    AvailabilityZone = "${data.aws_availability_zones.available.names[count.index]}"
    Name             = "${local.env} private subnet ${count.index}"
    Terraform        = "true"
    Environment      = "${local.env}"
  }
}
#--------------------------------------------------------
#--Internet gateway for Integration Platform VPC
#--------------------------------------------------------
resource "aws_internet_gateway" "intgw" {
  vpc_id = "${aws_vpc.eleksintegration.id}"

  tags {
    Name = "${local.env} internet gateway"
    Environment = "${local.env}"
  }
}
#------------------------------------------------------------------
#--Create route tables for Public Subnets to use Internet Gateway
#------------------------------------------------------------------
resource "aws_route" "internet" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.intgw.id}"
  route_table_id         = "${aws_vpc.eleksintegration.main_route_table_id}"
}
#----------------------------------------------------------------------------------------
#--Create a NAT gateway with an EIP for each public subnet
#----------------------------------------------------------------------------------------
resource "aws_eip" "intgw" {
  count      = "${local.config["aws_az_count"]}"
  vpc        = true
  depends_on = ["aws_internet_gateway.intgw"]
}

resource "aws_nat_gateway" "intgw" {
  count         = "${local.config["aws_az_count"]}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.intgw.*.id, count.index)}"

  tags {
    AvailabilityZone = "${data.aws_availability_zones.available.names[count.index]}"
    Name             = "${local.env} nat gateway ${count.index}"
    Terraform        = "true"
    Environment      = "${local.env}"
  }
}
#------------------------------------------------------------------
#--Create route tables for public and private subnets
#------------------------------------------------------------------
resource "aws_route_table" "public" {
  count  = "${local.config["aws_az_count"]}"
  vpc_id = "${aws_vpc.eleksintegration.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.intgw.id}"
  }
  tags {
    Name        = "${local.env} public route table ${count.index}"
    Terraform   = "true"
    Environment = "${local.env}"
  }
}
resource "aws_route_table" "private" {
  count  = "${local.config["aws_az_count"]}"
  vpc_id = "${aws_vpc.eleksintegration.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.intgw.*.id, count.index)}"
  }
  tags {
    Name        = "${local.env} private route table ${count.index}"
    Terraform   = "true"
    Environment = "${local.env}"
  }
}
#------------------------------------------------------------------
#--Assosiate route tables with public and private subnets
#------------------------------------------------------------------
resource "aws_route_table_association" "public" {
    count          = "${local.config["aws_az_count"]}"
    subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}
resource "aws_route_table_association" "private" {
  count          = "${local.config["aws_az_count"]}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
