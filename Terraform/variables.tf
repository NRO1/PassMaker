variable "profile" {
  type = string
  default = "NRO1"
}

variable "region" {
  type = string
  default = "eu-central-1"
}

############################# VPC ##########################

variable "vpcName" {
    type = string
    default = "NRO1_vpc"
}

variable "cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "azs" {
    type = list
    default = ["eu-central-1a", "eu-central-1b"]
}

variable "private_subnets" {
    type = list
    default = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
    type = list
    default = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "nat" {
    type = bool
    default = true
}

############################# ALB ##########################

variable "albName" {
    type = string
    default = "NRO1-ALB"
}

variable "albType" {
    type = string
    default = "application"
}

variable "TG_namePrefix" {
    type = string
    default = "NRO1-"
}

variable "TG_BEprotocol" {
    type = string
    default = "HTTP"
}

variable "TG_BEport" {
    type = number
    default = 80
}

variable "TG_targetType" {
    type = string
    default = "instance"
}

variable "listenerPort" {
    type = number
    default = 80
}

variable "listenerProtocol" {
    type = string
    default = "HTTP"
}

variable "listenerGI" {
    type = number
    default = 0
}

############################# Autoscaling ##########################

variable "asgName" {
    type = string
    default = "NRO1_ASG"
}

variable "asgMinSize" {
    type = number
    default = 1
}

variable "asgMaxSize" {
    type = number
    default = 2
}

variable "asgDesCapacity" {
    type = number
    default = 1
}

variable "asgHealth" {
    type = string
    default = "EC2"
}

variable "LT_name" {
    type = string
    default = "NRO1_LT"
}

variable "LT_instance_type" {
    type = string
    default = "t2.small"
}

variable "LT_ami" {
    type = string
    default = "ami-0a261c0e5f51090b1"
}

############################# ECS ##########################

variable "ECS_app_name" {
    type = string
    default = "PassMaker"
}

#########  FE vars

variable "FE_image" {
  type= string
  default = "docker.io/nrdevac1/passmaker-fe:latest"
}   

variable "FE_container_port" {
  type = number
  default = 80
}


#########  BE vars

variable "BE_image" {
  type= string
  default = "docker.io/nrdevac1/passmaker-be:latest"
}  

variable "BE_container_port" {
  type = number
  default = 8000
}
