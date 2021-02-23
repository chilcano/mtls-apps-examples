variable "ami" {
  type    = string
  default = "ami-068670db424b01e9a" // Amazon AWS, us-west-1, bionic, 18.04, amb64, hvm-ssd, 20190627.01
}

// ssh pub key used to connect to AWS EC2 instances
variable "key_name" {
  type    = string
  default = "terraform-key-name"
}

// the filename of ssh priv key used to connect remote-exec puppet provisioner
// it should be in ~/.ssh/<puppet-ssh-privkey-filename>
variable "puppet_ssh_privkey_filename" {
  type    = string
  default = "puppet-ssh-privkey-filename"
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "The aws region to deploy to"
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "The amount of versions of the infrastructer to make "
}

variable "PlaygroundName" {
  type        = string
  default     = "feb"
  description = "The playground name to tag all resouces with"
}

variable "instances" {
  type        = number
  default     = 1
  description = "number of instances per dns record"
}

variable "domain_name" {
  type        = string
  default     = "devopsplayground.org"
  description = "Your own registered domain name if using dns module"
}

// PLEASE TAKE CARE WHEN EDITING THIS DUE TO COSTS. 

variable "deploy_count" {
  type        = number
  description = "Change this for the number of users of the playground"
  default     = 1
}

variable "InstanceRole" {
  type        = number
  default     = null
  description = "The Role of the instance to take"
}

variable "instance_type" {
  type        = string
  description = "instance type to be used for instances"
  default     = "t2.medium"
}

variable "scriptLocation" {
  type        = string
  default     = "./modules/instance/scripts"
  description = "The location of the userData folder"
}

variable "policyLocation" {
  type        = string
  default     = "./../../policies"
  description = "The location of the policys"
}
