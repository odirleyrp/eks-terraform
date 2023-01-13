locals {
  common_tags = {
    Ambiente          = "HML"
    Projeto           = "BMG-DB"
    "Tipo de Capital" = "AWS"
    Terraform         = true
  }
}

data "aws_vpc" "default" {
  filter {
    name = "tag:Name"
    values = ["vpc-ehub"]
  }
}


data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
  tags = {
    Type = "private"
  }
}

module "SG" {
  source             = "git::git@ssh.dev.azure.com:v3/bbce0256/Infra%20as%20Code%20-%20BBCE/sg-eks"
  name_prefix        = "ehub-aurora-mysql-hml"
  ENV                = "hml"
  app                = "ehub"
  requerente         = "daniela fallopa"
  vpc_id             = data.aws_vpc.default.id
  services_ports     = var.services_ports
  IPS_VPC_ACCESS_EKS = [data.aws_vpc.default.cidr_block,"10.7.0.0/16"]
}

resource "aws_security_group_rule" "allow_access" {
  type                     = "ingress"
  from_port                = module.aurora.this_rds_cluster_port
  to_port                  = module.aurora.this_rds_cluster_port
  protocol                 = "tcp"
  cidr_blocks              = [data.aws_vpc.default.cidr_block,"10.7.0.0/16", "10.87.0.0/16"]
  security_group_id        = module.aurora.this_security_group_id
}

module "aurora" {
  source                = "./module/aurora-serverles"
  name                  = "ehub-aurora-mysql-hml"
  engine                = "aurora"
  engine_mode           = "serverless"
  replica_scale_enabled = false
  replica_count         = 0

  backtrack_window = 10 # ignored in serverless

  subnets                         = data.aws_subnet_ids.all.ids
  vpc_id                          = data.aws_vpc.default.id
  monitoring_interval             = 60
  instance_type                   = "db.r5.xlarge"
  apply_immediately               = true
  skip_final_snapshot             = true
  storage_encrypted               = true
  db_parameter_group_name         = aws_db_parameter_group.aurora_db_postgres96_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_postgres96_parameter_group.id
  source_region = "us-west-2"

  scaling_configuration = {
    auto_pause               = true
    max_capacity             = 64
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags   = merge(local.common_tags,
  {
    Name = "ehub-aurora-mysql-hml"
  })
}

resource "aws_db_parameter_group" "aurora_db_postgres96_parameter_group" {
  name        = "ehuib-hml"
  family      = "aurora5.6"
  description = "Parametros da familia do engine"

  tags   = merge(local.common_tags)
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres96_parameter_group" {
  name        = "ehub-hml"
  family      = "aurora5.6"
  description = "Parametros para o cluster"

  parameter {
  apply_method = "immediate"
  name         = "general_log"
  value        = "1"
  }
  parameter {
  apply_method = "immediate"
  name         = "slow_query_log"
  value        = "1"
  }
  parameter {
  apply_method = "pending-reboot"
  name         = "performance_schema"
  value        = "1"
  }

  tags   = merge(local.common_tags)
}