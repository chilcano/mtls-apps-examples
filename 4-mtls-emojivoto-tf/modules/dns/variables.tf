variable "instances" {
  type        = number
  description = "number of instances to create records for"
}
variable "instance_ips" {
  type        = list(string)
  description = "List of IP's of the instances being used  the DNS hosted zone "
}
variable "record_name" {
  type        = string
  description = "the name of the dns record to create"
}
variable "record_type" {
  type        = string
  description = "The dns record type to be used"
  default     = "A"
}
variable "record_ttl" {
  type        = number
  description = "defauly time to live for domain records"
  default     = 300
}
variable "domain_name" {
  type        = string
  description = "Hosted zone domain name"
}
