variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2_v2"
}

variable "subnet_id" {
  type = string
}

