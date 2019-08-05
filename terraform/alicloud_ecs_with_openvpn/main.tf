terraform {
  required_version = ">= 0.12"
}

provider "alicloud" {
  region = "cn-shanghai"
}

variable "openvpn_proto" {
  default = "tcp"
}

module "ecs_with_openvpn" {
  source = "git::https://github.com/guanwei/terraform-modules//alicloud/ecs-instance"

  name           = "ecs_with_openvpn"
  image_id       = "centos_7_06_64_20G_alibase_20190711.vhd"
  password       = "Just4Demo"
  vpc_name_regex = "default"
  security_group_rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "22/22"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    },
    {
      type        = "ingress"
      ip_protocol = "${var.openvpn_proto}"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "1194/1194"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    },
  ]
  eip = {
    bandwidth = 50
  }
  sleep_time = 60
  playbook_file = "ansible/playbook.yml"
  playbook_extra_vars = {
    openvpn_proto = "${var.openvpn_proto}"
  }
}

output "public_ips" {
  value = "${module.ecs_with_openvpn.public_ips}"
}

output "private_ips" {
  value = "${module.ecs_with_openvpn.private_ips}"
}
