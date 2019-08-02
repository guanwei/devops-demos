terraform {
  required_version = ">= 0.12"
}

provider "alicloud" {
  region = "cn-shanghai"
}

module "ecs_with_jumpserver" {
  source = "git::https://github.com/guanwei/terraform-modules//alicloud/ecs-instance"

  name                       = "ecs_with_jumpserver"
  image_id                   = "centos_7_06_64_20G_alibase_20190711.vhd"
  internet_max_bandwidth_out = 50
  password                   = "Just4Demo"
  vpc_name_regex             = "default"
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
      port_range  = "80/80"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "2222/2222"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    },
  ]
  sleep_time    = 60
  playbook_file = "ansible/playbook.yml"
}

output "public_ips" {
  value = "${module.ecs_with_jumpserver.public_ips}"
}
