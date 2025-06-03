
variable "vpc_id" {}
variable "public_subnets" {
  type = list(string)
}
variable "acm_cert_arn" {}
variable "lb_sg_id" {}
