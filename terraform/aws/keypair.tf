#--------------------------------------------------------
#--Import pre-generated key-pair to aws
#--------------------------------------------------------
resource "aws_key_pair" "deployer" {
  key_name   = "${local.config["key_name"]}"
  public_key = "${file("${local.config["key_path_local"]}${local.config["key_name"]}.pub")}"
}