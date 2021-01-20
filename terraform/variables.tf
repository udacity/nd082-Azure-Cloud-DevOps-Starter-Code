variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "udacity-azure-webserver"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "UK South"
}

variable "resource_group" {
  description = "Name of the resource group, including the -rg"
  default     = "udacity-WSproject-rg"
  type        = string
}

variable "vm_size" {
  default     = "Standard_B1ls"
  description = "The size of the VM"
}

variable "vm_instances" {
  description = "Number of VM instances"
  type        = number
  default     = 4
}

variable "num_of_vms" {
  description = "Number of VM resources to be  created behnd the load balancer"
  default     = 2
  type        = number
}

variable "addressprefix" {
  default = "10.1.0.0/16"

}

variable "subnetprefix" {
  default = "10.1.0.0/24"
}
