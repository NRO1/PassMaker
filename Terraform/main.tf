############################# VPC ##########################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"
    
  name = var.vpcName
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.nat

  tags = {
    project = "NRO1_PassMaker"
  }
}

############################# ALB ##########################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = var.albName

  load_balancer_type = var.albType

  vpc_id             =  module.vpc.vpc_id
  subnets            =  module.vpc.public_subnets
  #security_groups    =  module.vpc.default_security_group_id

  target_groups = [{
      name_prefix      = var.TG_namePrefix
      backend_protocol = var.TG_BEprotocol
      backend_port     = var.TG_BEport
      target_type      = var.TG_targetType
    }
  ]

  http_tcp_listeners = [
    {
      port               = var.listenerPort
      protocol           = var.listenerProtocol
      target_group_index = var.listenerGI
    }
  ]

  tags = {
    project = "NRO1_PassMaker"
  }
}

############################# Autoscaling ##########################

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.7.0"

  name = var.asgName
  min_size                  = var.asgMinSize
  max_size                  = var.asgMaxSize
  desired_capacity          = var.asgDesCapacity
  health_check_type         = var.asgHealth
  vpc_zone_identifier       = module.vpc.private_subnets

  # Launch template
  launch_template_name       = var.LT_name
  image_id          = var.LT_ami
  instance_type     = var.LT_instance_type

  tags = {
    project = "NRO1_PassMaker"
  }
}

############################ ECS ##########################

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.ECS_app_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
     project = "NRO1_PassMaker"
  }
}

resource "aws_cloudwatch_log_group" "log-group-FE" {
  name = "${var.ECS_app_name}-FE-logs"

  tags = {
    project = "NRO1_PassMaker"
  }
}

resource "aws_cloudwatch_log_group" "log-group-BE" {
  name = "${var.ECS_app_name}-BE-logs"

  tags = {
    project = "NRO1_PassMaker"
  }
}

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.ECS_app_name}-cluster"
  tags = {
     project = "NRO1_PassMaker"
  }
}


resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.ECS_app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.ECS_app_name}-FE-container",
      "image": "${var.FE_image}",
      "entryPoint": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group-FE.id}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "${var.ECS_app_name}-FE"
        }
      },
      "portMappings": [
        {
          "containerPort": ${var.FE_container_port},
          "hostPort": ${var.FE_container_port}
        }
      ],
      "cpu": 512,
      "memory": 512,
      "networkMode": "awsvpc"
    },
     {
      "name": "${var.ECS_app_name}-BE-container",
      "image": "${var.BE_image}",
      "entryPoint": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group-BE.id}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "${var.ECS_app_name}-BE"
        }
      },
      "portMappings": [
        {
          "containerPort": ${var.BE_container_port},
          "hostPort": ${var.BE_container_port}
        }
      ],
      "cpu": 512,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "2048"
  cpu                      = "1024"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
     project = "NRO1_PassMaker"
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}


resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.ECS_app_name}-ecs-service"
  cluster              =  aws_ecs_cluster.aws-ecs-cluster.arn
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = module.vpc.private_subnet_arns
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "${var.ECS_app_name}-container"
    container_port   = 8000
  }

 // depends_on = [aws_lb_listener.listener]
}