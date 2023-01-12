locals {
  common_tags  = {
    Ambiente          = "HML"
    Projeto           = "goLisa"
    "Tipo de Capital" = "CAPEX"
    Terraform         = true
  }
}

data aws_acm_certificate bbce {
  domain      = "*.bbce.tech"
  types       = ["IMPORTED"]
  most_recent = true
}

data aws_route53_zone zone {
  name         = "bbce.tech"
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
    Type = "private"
  }
}

module sg {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/security-group"
  name   = "sg_goliza"
  vpc_id = data.aws_vpc.vpc.id
  sg_ingress = {
    "80"    = ["0.0.0.0/0"],
    "443"    = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags)
}

module sg_rule {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/security-group-rule"
  security_group_id = module.sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

module sg_rule_ingress {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/security-group-rule"
  security_group_id = module.sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

module sg_alb {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/security-group"
  name       = "sg_alb_goliza"
  vpc_id     = data.aws_vpc.vpc.id
  sg_ingress = {
    "80"   = ["10.87.0.0/16", "10.47.0.0/16"],
    "443"   = ["10.87.0.0/16", "10.47.0.0/16"]
  }
  tags = merge(local.common_tags)
}

module sg_rule_alb {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/security-group-rule"
  security_group_id = module.sg_alb.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

module s3 {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/bucket-s3"
  s3_name       = "hml-goliza-logs-alb"
  s3_versioning = false
  force_destroy = true
  s3_policy     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::797873946194:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hml-goliza-logs-alb/alb/AWSLogs/993324252386/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hml-goliza-logs-alb/alb/AWSLogs/993324252386/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::hml-goliza-logs-alb"
    }
  ]
}
POLICY
  s3_tags = merge(local.common_tags)
}

module alb {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/aws-load-balancer//alb?ref=v0.0.6"
  alb_name                       = "hml-goliza-web-alb"
  internal_type                  = true
  subnets                        = data.aws_subnet_ids.private.ids
  security_groups                = [module.sg_alb.id]
  log_bucket                     = module.s3.id
  log_prefix                     = "alb"
  enable_deletion_protection     = false
  target_group_name              = "hml-goliza-web-tg"
  target_group_port              = 80
  target_group_protocol          = "HTTP"
  vpc_id                         = data.aws_vpc.vpc.id
  target_group_target_type       = "ip"
  deregistration_delay           = 300
  health_check_protocol          = "HTTP"
  health_check_matcher           = 200
  health_check_path              = "/"
  listener_https                 = true
  #listener_port                 = 80
  #listener_protocol             = "HTTP"
  https_listener_port            = 443
  https_listener_protocol        = "HTTPS"
  https_listener_policy          = "ELBSecurityPolicy-2016-08"
  https_listener_certificate_arn = data.aws_acm_certificate.bbce.arn

  tags = merge(local.common_tags)
}

module goliza_record {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/route53-record"
  route53_zone_id  = data.aws_route53_zone.zone.zone_id
  route53_dns_name = "cadastro"
  route53_type     = "A"
  route53_ttl      = "60"
  route53_records  = ["44.240.116.217"]
}


########################################### ALB API
module alb_api {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/aws-load-balancer//alb?ref=v0.0.6"
  alb_name                       = "hml-goliza-api-alb"
  internal_type                  = true
  subnets                        = data.aws_subnet_ids.private.ids
  security_groups                = [module.sg_alb.id]
  log_bucket                     = module.s3_api.id
  log_prefix                     = "alb-api"
  enable_deletion_protection     = false
  target_group_name              = "hml-goliza-api-tg"
  target_group_port              = 80
  target_group_protocol          = "HTTP"
  vpc_id                         = data.aws_vpc.vpc.id
  target_group_target_type       = "ip"
  deregistration_delay           = 300
  health_check_protocol          = "HTTP"
  health_check_matcher           = 200
  health_check_path              = "/health"
  listener_https                 = true
  #listener_port                 = 80
  #listener_protocol             = "HTTP"
  https_listener_port            = 443
  https_listener_protocol        = "HTTPS"
  https_listener_policy          = "ELBSecurityPolicy-2016-08"
  https_listener_certificate_arn = data.aws_acm_certificate.bbce.arn

  tags = merge(local.common_tags)
}


module s3_api {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/bucket-s3"
  s3_name       = "hml-goliza-logs-alb-api"
  s3_versioning = false
  force_destroy = true
  s3_policy     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::797873946194:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hml-goliza-logs-alb-api/alb-api/AWSLogs/993324252386/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::hml-goliza-logs-alb-api/alb-api/AWSLogs/993324252386/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::hml-goliza-logs-alb-api"
    }
  ]
}
POLICY
  s3_tags = merge(local.common_tags)
}




module goliza_record_api {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/route53-record"
  route53_zone_id  = data.aws_route53_zone.zone.zone_id
  route53_dns_name = "api-cadastro"
  route53_type     = "A"
  route53_ttl      = "60"
  #route53_records  = [module.alb_api.dns_name]
  route53_records  = ["44.240.116.217"]

}







