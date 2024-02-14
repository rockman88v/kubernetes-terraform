variable "region" {
  type    = string
  default = "ap-southeast-1"
}
variable "vpc_id" {
  type    = string
  default = ""
}
variable "cluster_prefix" {
  type    = string
  default = "vietops"
}

variable "keypair_name" {
  type        = string
  description = "Key pair name you wanted to assign to both control plane and worker node"
}

variable "master_instance_type" {
  type        = string
  description = "Instance type master"
}

variable "worker_instance_type" {
  type        = string
  description = "Instance type master"
}

variable "master_instance_name" {
  type        = string
  default = "control-plane"
  description = "Control Plane instance name"
}

variable "worker_instance_name" {
  type        = string
  description = "Control Plane instance name"
}

variable "number_of_workers" {
  type        = number
  description = "Number of worker nodes that you want to create"
  default     = 1
}

variable "included_components" {
  type        = list(any)
  description = "Select which component should be installed with the kubernetes cluster"
  default     = []
}
