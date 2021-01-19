variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "udacity"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "UK South"
}

variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
}

variable "admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements"
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

variable "addressprefix" {
  default = "10.1.0.4/24"
}

variable "subnetprefix" {
  default = "10.1.0.0/24"
}
