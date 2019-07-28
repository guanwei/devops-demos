terraform {
  required_version = ">= 0.12"
}

provider "alicloud" {
  region = "cn-shanghai"
}

variable "consul_address" {
  default = "127.0.0.1:8500"
}

module "ecs_with_node_exporter" {
  source = "git::https://github.com/guanwei/terraform-modules//alicloud/ecs-instance"

  name                       = "ecs_with_node_exporter"
  image_id                   = "centos_7_06_64_20G_alibase_20190711.vhd"
  internet_max_bandwidth_out = 50
  password                   = "Just4Demo"
  # vpc_id                     = "vpc-********"
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
      ip_protocol = "tcp"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "9100/9100"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    },
  ]
  sleep_time    = 60
  playbook_file = "ansible/playbook.yml"
  playbook_extra_vars = {
    consul_address = "${var.consul_address}"
  }
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command = "ansible-playbook -e '{\"consul_address\":\"${var.consul_address}\", \"service_addresses\":[${join(",", module.ecs_with_node_exporter.private_ips)}]}' ansible/cleanup_playbook.yml"
    when    = "destroy"
  }
}
