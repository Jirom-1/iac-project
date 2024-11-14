variable "alb_port" {
  type = number
  default = 80
}
variable "project-name" {
    type = string  
}

variable "subnets" {
    type = list(string)
}

variable "vpc_id" {
  type = string
}

# variable "security_groups" {
#   type = list(string)
# }