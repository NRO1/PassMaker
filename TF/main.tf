terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.48.0"
    }
  }
}

provider "aws" {
     profile = var.profile
}


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
    project = "HS_project"
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
    project = "HS_project"
  }
}

