terraform {
  required_version = ">= 0.12"
}

provider "alicloud" {
  region = "cn-shanghai"
}

variable "consul_address" {
  default = "127.0.0.1:8500"
}

variable "node_exporter_port" {
  default = 9100
}

variable "node_exporter_consul_service_name_prefix" {
  default = "node-exporter"
}

module "ecs_with_node_exporter" {
  source = "git::https://github.com/guanwei/terraform-modules//alicloud/ecs-instance"

  name     = "ecs_with_node_exporter"
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
      ip_protocol = "tcp"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "${var.node_exporter_port}/${var.node_exporter_port}"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    },
  ]
  eip = {
    bandwidth = 50
  }
  sleep_time    = 60
  playbook_file = "playbook.yml"
  playbook_extra_vars = {
    consul_address      = "${var.consul_address}"
    service_name_prefix = "${var.node_exporter_consul_service_name_prefix}"
    service_port        = "${var.node_exporter_port}"
    service_tags        = ["node-exporter", "metrics"]
    http_path           = "/metrics"
    interval            = "30s"
    timeout             = "3s"
  }
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command = "ansible-playbook -e '{\"consul_address\":\"${var.consul_address}\", \"service_name_prefix\": \"${var.node_exporter_consul_service_name_prefix}\", \"service_addresses\":[${join(",", module.ecs_with_node_exporter.private_ips)}]}' cleanup_playbook.yml"
    when    = "destroy"
  }
}

output "public_ips" {
  value = "${module.ecs_with_node_exporter.public_ips}"
}

output "private_ips" {
  value = "${module.ecs_with_node_exporter.private_ips}"
}