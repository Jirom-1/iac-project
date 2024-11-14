variable "project_name" {
  type = string
}

variable "container_name" {
    type = string
}

variable "image_name" {
    type = string
}

variable "private_registry_secret_arn" {
    type = string
}

variable "port" {
    type = number
}

variable "subnets" {
    type = list(string)   
}

# variable "security_groups_id" {
#     type = list(string)  
# }

variable "alb_target_group_arn" {
  type = string
}

variable "vpc_id" {
    type = string  
}