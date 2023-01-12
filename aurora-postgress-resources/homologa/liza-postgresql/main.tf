locals {
  common_tags  = {
    Ambiente          = "HML"
    Projeto           = "LIZA"
    "Tipo de Capital" = "CAPEX"
    Terraform         = true
  }
}

data aws_vpc vpc {
  filter {
    name = "tag:Name"
    values = ["vpc-lisa"]
  }
}

data aws_subnet_ids private {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    "Type" = "private"
  }
}


#############
# RDS Aurora
#############
module "aurora" {
  source                          = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/postgress-serverless"
  name                            = "goliza-db-hml"
  engine                          = "aurora-postgresql"
  engine_version                  = "13.6"
  engine_mode                     = "provisioned"
  subnets                         = data.aws_subnet_ids.private.ids
  vpc_id                          = data.aws_vpc.vpc.id
  #replica_count                   = 1
  instance_type                   = "db.t3.medium"
  #instance_type_replica           = "db.t3.medium"
  apply_immediately               = true
  skip_final_snapshot             = true
  db_parameter_group_name         = aws_db_parameter_group.aurora_db_postgres13_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_postgres13_parameter_group.id
  //  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  security_group_description = ""
  copy_tags_to_snapshot = true
  deletion_protection = false
  preferred_backup_window = "05:00-06:00"
  preferred_maintenance_window = "sun:06:00-sun:07:30"

 


  tags = merge(local.common_tags,
  {
    Name = "goliza-db-hml"
  })
}

resource "aws_db_parameter_group" "aurora_db_postgres13_parameter_group" {
  name        = "liza-aurora-db-postgres13-parameter-group"
  family      = "aurora-postgresql13"
  description = "liza-aurora-db-postgres13-parameter-group"

  tags = merge(local.common_tags)
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres13_parameter_group" {
  name        = "liza-aurora-postgres13-cluster-parameter-group"
  family      = "aurora-postgresql13"
  description = "liza-aurora-postgres13-cluster-parameter-group"

  tags = merge(local.common_tags)
}

############################
# Example of security group
############################
resource "aws_security_group" "app_servers" {
  name_prefix = "app-servers-"
  description = "For application servers"
  vpc_id      = data.aws_vpc.vpc.id

  tags = merge(local.common_tags)
}

resource "aws_security_group_rule" "allow_access" {
  type                     = "ingress"
  from_port                = module.aurora.this_rds_cluster_port
  to_port                  = module.aurora.this_rds_cluster_port
  protocol                 = "tcp"
  cidr_blocks              = [data.aws_vpc.vpc.cidr_block,"10.7.0.0/16", "10.87.0.0/16"]
  security_group_id        = module.aurora.this_security_group_id
}