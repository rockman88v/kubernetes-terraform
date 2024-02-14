# variable "cluster_name" {
#   type        = string
#   description = "cluster name will be added as prefix for other resource to avoid resource name collision"
# }

variable "cluster_prefix" {
  type        = string
  description = "cluster_name_prefix will be added as prefix for other resource to avoid resource name collision"
}

variable "bootstrap_script" {
  type    = string
  default = ""
}

variable "ami" {
  type    = string
  default = "ami-08be951cec06726be"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_xxx" {
  type    = string
  default = "t2.micro"
}

variable "bootstrap_script_file" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "keypair_name" {
  type = string
}

variable "number_of_instances" {
  type    = number
  default = 1
}

# variable "role" {
#   type = string
#   description = "Role name to be added into multiple ec2 instances"
#   default = null
# }

variable "ec2_role" {
  type = string
  description = "Role name to be added into multiple ec2 instances"
  default = null
}