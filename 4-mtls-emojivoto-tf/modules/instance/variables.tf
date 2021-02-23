variable "security_group_ids" {
  type        = list(string)
  description = "An array of security groups for the instance"
}
variable "subnet_id" {
  type        = string
  description = "The id of the subnet"
}
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The type of instance"
}
variable "instance_count" {
  type        = number
  default     = 1
  description = "The amount of instances to create"
}
variable "user_data" {
  type        = string
  default     = ""
  description = "Custom user data to run on first start"
}
variable "amiName" {
  type        = string
  default     = "amzn2-ami-hvm*"
  description = "The name of the ami to run on the instance"
}
variable "amiOwner" {
  type        = string
  default     = "amazon"
  description = "The Owner of the ami to run on the instance"
}
variable "PlaygroundName" {
  type        = string
  description = "The name of the playground for tagging"
}
variable "profile" {
  default     = null
  type        = string
  description = "The Role of the instance to take"
}
variable "associate_public_ip_address" {
  type        = bool
  default     = true
  description = "Should aws give the instance a public ip"
}
variable "purpose" {
  type        = string
  default     = "Playground"
  description = "A tag to give each resource"
}

