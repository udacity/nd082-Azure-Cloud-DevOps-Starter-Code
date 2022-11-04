variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "hiepdang"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "East US"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    Name = "hiepdang-webserver"
    Provider = "azure"
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of Azure resource group"
  default     = "hiepdang"
}

variable "admin_username" {
  description = "The Virtual machine admin username"
  default     = "hiepudacity"
}

variable "admin_password" {
  description = "The Virtual admin Machine password"
  default     = "Abcd@1234"
}

variable "vm_count" {
  type        = number
  description = "The number of virtual machines to create"
  default     = 2
}

variable "imageid" {
  description = "The ID of the Packer Image created"
  default     = "/subscriptions/4f9f2e79-1bd1-496d-b27a-4d875eff0d35/resourceGroups/hiepdang/providers/Microsoft.Compute/images/LinuxImage"
}
