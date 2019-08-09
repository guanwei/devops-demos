terraform {
  required_version = ">= 0.12"
}

provider "alicloud" {
  region = "cn-shanghai"
}

module "ecs_with_jumpserver" {
  source = "git::https://github.com/guanwei/terraform-modules//alicloud/ecs-instance"

  name     = "ecs_with_jumpserver"
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
  eip = {
    bandwidth = 50
  }
  sleep_time    = 10
  playbook_file = "playbook.yml"
  playbook_extra_vars = {
    mariadb_root_password  = "Q1w2e3r4"
    jumpserver_db_password = "jumpserver"
    secret_key             = "uQguZIl3tmBVsyUA2uRnV7VsIlECvsss0pIUY4COxoH2nEsSwR"
    bootstrap_token        = "an2wB0TEqMgB8EMn"
  }
}

output "public_ips" {
  value = "${module.ecs_with_jumpserver.public_ips}"
}

output "private_ips" {
  value = "${module.ecs_with_jumpserver.private_ips}"
}
