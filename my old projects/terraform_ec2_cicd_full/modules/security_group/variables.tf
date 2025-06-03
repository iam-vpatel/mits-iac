
variable "vpc_id" {}
variable "vpc_cidrs" {
  type = list(string)
}
variable "bastion_cidrs" {
  type = list(string)
}
