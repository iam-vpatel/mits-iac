
variable "instance_count" {
  default = 1
}

variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "hostname" {}
variable "domain_name" {}
variable "tags" {
  type = map(string)
}
