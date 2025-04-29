variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "honeynetx"
}


variable "location" {
  description = "Azure region to deploy to"
  type        = string
  default     = "East US"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  default     = "HoneyNetX!"
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_D2s_v3"
}

