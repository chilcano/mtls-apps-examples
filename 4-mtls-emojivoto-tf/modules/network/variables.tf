variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Internal CIDR Block for the VPC"
}
variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Enable a dns on the vpc"
}
variable "required_subnets" {
  type        = number
  default     = 2
  description = "Number of Public subnets in the VPC. By default this number is 2, and should always be higher or equal to 2, so a load balancer and other resources could be created without AWS complaining"
}

variable "private_subnets" {
  type        = number
  default     = 0
  description = "Number of Private subnets in the VPC. By default this number is 0. If you create private subnets, you perhaps want to put autoscaling groups and/or loadbalancers into it, so mind that you'll probably need more than 1."
}

variable "PlaygroundName" {
  type        = string
  description = "The name of the playground for tagging"
}
variable "purpose" {
  type        = string
  default     = "Playground"
  description = "A tag to give each resource"
}

variable "deploy_count" {
  default = 1
}