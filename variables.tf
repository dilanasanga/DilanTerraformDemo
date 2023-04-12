variable "location" {
  type = string
  description = "Azure AKS location"
}

variable "resource_group_name" {
  type = string
  description = "Azure AKS resource group name"
}

variable "node_count" {
    type = number
    description = "Number of nodes in the cluser"
}

variable "kubernetes_version" {
    type = string
    description = "K8s version"
}