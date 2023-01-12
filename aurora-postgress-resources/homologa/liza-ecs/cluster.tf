data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc-lisa"]
  }
}

data "aws_subnet" "subnet" {
  for_each = data.aws_subnet_ids.subnet.ids
  id       = each.value
}

data "aws_subnet_ids" "subnet" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_lb_target_group" "tg-web" {
  name = var.lb_tg_web
}

data "aws_lb_target_group" "tg-api" {
  name = var.lb_tg_api
}




resource "aws_ecs_cluster" "goliza-web" {

    capacity_providers = [
        "FARGATE",
        "FARGATE_SPOT",
    ]

    name               = "${var.name_web}-cluster"
    tags               = {
        "Name" = "${var.name_web}-cluster"  
        "ambiente" = "hml"
        "projeto" = "goliza"      
        "Terraform" = "true"
    }
}


module "sg-goliza" {
  source = "../security-group"
  name = "sg_goliza_ecr"
  vpc_id = data.aws_vpc.vpc.id

  sg_ingress = {
	"80" = ["10.47.0.0/16"] 
  }

  
  tags = {
    app = "goLiza"
    ambiente = "homologa"
    modalidade = "projeto"
    requerinte = "Raphael Luna"
    Name = "sg-goliza-ecr"
  }
  }



########
# aws_ecs_service.goliza-web-service:
resource "aws_ecs_service" "goliza-web-service" {

    cluster = aws_ecs_cluster.goliza-web.id
    deployment_maximum_percent         = 200 
    deployment_minimum_healthy_percent = 100 
    desired_count                      = 1   
    enable_ecs_managed_tags            = true
    health_check_grace_period_seconds  = 0
    launch_type                        = "FARGATE"
    name                               = "${var.name_web}-service"
    platform_version                   = "LATEST"
    scheduling_strategy                = "REPLICA"
    tags                               = {
          "Name" = "${var.name_web}-service"   
          "ambiente" = "hml"
          "projeto" = "goliza"
          "Terraform" = "true"
    }
    task_definition                    = "${var.name_web}-taskdefinition"

    deployment_controller {
        type = "ECS"
    }

    load_balancer {
        container_name   = "${var.name_web}-container"
        container_port   = 80
        target_group_arn = data.aws_lb_target_group.tg-web.arn
        
    }

    network_configuration {
        assign_public_ip = false
        security_groups  = ["${module.sg-goliza.id}"]
        
        subnets  = data.aws_subnet_ids.subnet.ids
    }

    timeouts {}
}

# aws_ecs_task_definition.goliza-web-task:
resource "aws_ecs_task_definition" "goliza-web-task" {

    container_definitions    = jsonencode(
        [
            {
                cpu              = 0
                environment      = [
                    {
                        name  = "ASPNETCORE_ENVIRONMENT"
                        value = "Development"
                    },
                ]
                essential        = true
                image            = "993324252386.dkr.ecr.us-west-2.amazonaws.com/goliza-web-bbce-shared:495ddf17607d57e0bfd3b4630938c2044e644ef9"
                logConfiguration = {
                    logDriver = "awslogs"
                    options   = {
                        awslogs-group         = "/ecs/${var.name_web}-taskdefinition"
                        awslogs-region        = "us-west-2"
                        awslogs-stream-prefix = "ecs"
                    }
                }
                mountPoints      = []
                name             = "${var.name_web}-container"
                portMappings     = [
                    {
                        containerPort = 80
                        hostPort      = 80
                        protocol      = "tcp"
                    },
                ]
                volumesFrom      = []
            },
        ]
    )
    cpu                      = "256"
    execution_role_arn       = "arn:aws:iam::993324252386:role/ecsTaskExecutionRole"
    family                   = "${var.name_web}-taskdefinition"

    memory                   = "512"
    network_mode             = "awsvpc"
    requires_compatibilities = [
        "FARGATE",
    ]

    tags                     = {
        "Name" = "${var.name_web}-task-definition"  
        "ambiente" = "hml"
        "projeto" = "goliza" 
        "Terraform" = "true"
    }
    task_role_arn            = "arn:aws:iam::993324252386:role/ecsTaskExecutionRole"
}

#############################################################
############################ - Goliza API - ###################
#############################################################

#aws_ecs_cluster.goliza-api:
resource "aws_ecs_cluster" "goliza-api" {
    #arn                = "arn:aws:ecs:us-west-2:993324252386:cluster/${var.name_api}-cluster"
    capacity_providers = [
        "FARGATE",
        "FARGATE_SPOT",
    ]
    #id                 = "arn:aws:ecs:us-west-2:993324252386:cluster/${var.name_api}-cluster"
    name               = "${var.name_api}-cluster"
    tags               = {
        "Name" = "${var.name_api}-cluster"
    }
}

# aws_ecs_service.goliza-api-service:
resource "aws_ecs_service" "goliza-api-service" {
    cluster                            = aws_ecs_cluster.goliza-api.id
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    desired_count                      = 1
    enable_ecs_managed_tags            = true
    health_check_grace_period_seconds  = 0
    launch_type                        = "FARGATE"
    name                               = "${var.name_api}-service"
    platform_version                   = "LATEST"
    scheduling_strategy                = "REPLICA"
    tags                               = {}
    task_definition                    = "${var.name_api}-taskdefinition"

    deployment_controller {
        type = "ECS"
    }

    load_balancer {
        container_name   = "${var.name_api}-container"
        container_port   = 80
        target_group_arn = data.aws_lb_target_group.tg-api.arn
      
    }

    network_configuration {
        assign_public_ip = false
        security_groups  = ["${module.sg-goliza.id}"]

        subnets  = data.aws_subnet_ids.subnet.ids
    }

    timeouts {}
}

# aws_ecs_task_definition.goliza-api-task:
resource "aws_ecs_task_definition" "goliza-api-task" {
    container_definitions    = jsonencode(
        [
            {
                cpu              = 0
                environment      = [
                    {
                        name  = "ASPNETCORE_ENVIRONMENT"
                        value = "Development"
                    },
                ]
                essential        = true
                image            = "993324252386.dkr.ecr.us-west-2.amazonaws.com/goliza-api-bbce-shared:d1a087bb325daa02d9ec6caa82ac850e66d4f3c9"
                logConfiguration = {
                    logDriver = "awslogs"
                    options   = {
                        awslogs-group         = "/ecs/${var.name_api}-taskdefinition"
                        awslogs-region        = "us-west-2"
                        awslogs-stream-prefix = "ecs"
                    }
                }
                mountPoints      = []
                name             = "${var.name_api}-container"
                portMappings     = [
                    {
                        containerPort = 80
                        hostPort      = 80
                        protocol      = "tcp"
                    },
                ]
                volumesFrom      = []
            },
        ]
    )
    cpu                      = "256"
    execution_role_arn       = "arn:aws:iam::993324252386:role/ecsTaskExecutionRole"
    family                   = "${var.name_api}-taskdefinition"
    memory                   = "512"
    network_mode             = "awsvpc"
    requires_compatibilities = [
        "FARGATE",
    ]
    tags                     = {}
    task_role_arn            = "arn:aws:iam::993324252386:role/ecsTaskExecutionRole"
}