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

  depends_on = [module.vpc]
  name = var.asgName

  min_size                  = var.asgMinSize
  max_size                  = var.asgMaxSize
  desired_capacity          = var.asgDesCapacity
  health_check_type         = var.asgHealth
  vpc_zone_identifier       = var.private_subnets

  # Launch template
  launch_template_name       = var.LT_name
  image_id          = var.LT_ami
  instance_type     = var.LT_instance_type

  tags = {
    project = "NRO1_PassMaker"
  }
}










/*resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.app_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${var.app_name}-iam-role"
    Environment = var.app_environment
  }
}

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



data "template_file" "env_vars" {
  template = file("env_vars.json")
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.app_environment}-container",
      "image": "${aws_ecr_repository.aws-ecr.repository_url}:latest",
      "entryPoint": [],
      "environment": ${data.template_file.env_vars.rendered},
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.app_name}-${var.app_environment}"
        }
      },
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.app_environment
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}


resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.app_environment}-container"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.listener]
}*/