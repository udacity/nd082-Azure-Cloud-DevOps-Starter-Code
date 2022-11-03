variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "udacity"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "Southeast Asia"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    Name = "udacity-azure-webserver"
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of Azure resource group"
  default     = "udacity-demo-packer-rg"
}

variable "admin_username" {
  description = "The Virtual machine admin username"
  default     = "adminuser"
}

variable "admin_password" {
  description = "The Virtual admin Machine password"
  default     = "Admin@123"
}

variable "vm_count" {
  type        = number
  description = "The number of virtual machines to create"
  default     = 2
}

variable "imageid" {
  description = "The ID of the Packer Image created"
  default     = "/subscriptions/0bf66a04-23c0-4307-90cd-dae3b7ec4c35/resourceGroups/udacity-demo-packer-rg/providers/Microsoft.Compute/images/udacity-demo-packer-image"
}