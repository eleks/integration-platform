# module to evaluate ports 
variable "ports" {
  type = "map"
}
variable "index" {
}

locals {
  ports_all = "${values(var.ports)}"
}

data "template_file" "util-ports" {
  template = "$${v}"
  count    = "${length(var.ports)}"
  vars {
    v = "${ element(split(" ", local.ports_all[count.index]),var.index)  }"
  }
}

output "ports"{
  value = "${data.template_file.util-ports.*.rendered}"
}
