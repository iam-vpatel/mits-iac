
variable "instances" {
  type = map(object({
    ami            = string
    instance_type  = string
    subnet_id      = string
    tags           = map(string)
  }))
}
