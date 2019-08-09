terraform {
  required_version = ">= 0.12"
}

provider "alicloud" {
  region = "cn-shanghai"
}

variable "openvpn_proto" {
  default = "tcp"
}

variable "openvpn_port" {
  default = "1194"
}

module "ecs_with_openvpn" {
  source = "git::https://github.com/guanwei/terraform-modules//alicloud/ecs-instance"

  name     = "ecs_with_openvpn"
  image_id = "centos_7_06_64_20G_alibase_20190711.vhd"
  password = "Just4Demo"
  vpc_id   = "vpc-********"
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
      port_range  = "${var.openvpn_port}/${var.openvpn_port}"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    },
  ]
  eip = {
    bandwidth = 50
  }
  sleep_time    = 10
  playbook_file = "playbook.yml"
  playbook_extra_vars = {
    ca_password   = "06yNFfIJUBcPPVpQ"
    openvpn_proto = "${var.openvpn_proto}"
    openvpn_port  = "${var.openvpn_port}"
    openvpn_clients = [
      "client01",
      "client02"
    ]
    openvpn_clients_revoke = [
      "client02"
    ]
    openvpn_download_clients = "true"
    openvpn_download_dir     = "openvpn_clients/"
  }
}

output "public_ips" {
  value = "${module.ecs_with_openvpn.public_ips}"
}

output "private_ips" {
  value = "${module.ecs_with_openvpn.private_ips}"
}
