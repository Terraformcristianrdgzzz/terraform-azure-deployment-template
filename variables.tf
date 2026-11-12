variable "resource_group_name" {
  description = "Existing resource group where network and web server resources will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the deployment."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string

  validation {
    condition     = length(trimspace(var.vnet_name)) > 0
    error_message = "vnet_name must not be empty."
  }
}

variable "vnet_address_space" {
  description = "IPv4 CIDR address spaces for the virtual network."
  type        = list(string)

  validation {
    condition     = length(var.vnet_address_space) > 0 && alltrue([for prefix in var.vnet_address_space : can(cidrnetmask(prefix))])
    error_message = "vnet_address_space must contain one or more valid IPv4 CIDR prefixes."
  }
}

variable "subnet_name" {
  description = "Name of the web server subnet."
  type        = string

  validation {
    condition     = length(trimspace(var.subnet_name)) > 0
    error_message = "subnet_name must not be empty."
  }
}

variable "subnet_prefixes" {
  description = "IPv4 CIDR prefixes for the web server subnet."
  type        = list(string)

  validation {
    condition     = length(var.subnet_prefixes) > 0 && alltrue([for prefix in var.subnet_prefixes : can(cidrnetmask(prefix))])
    error_message = "subnet_prefixes must contain one or more valid IPv4 CIDR prefixes."
  }
}

variable "vm_name" {
  description = "Name of the Linux virtual machine."
  type        = string

  validation {
    condition     = length(trimspace(var.vm_name)) > 0 && length(var.vm_name) <= 64
    error_message = "vm_name must contain between 1 and 64 characters."
  }
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string

  validation {
    condition     = length(trimspace(var.admin_username)) > 0 && !strcontains(var.admin_username, " ")
    error_message = "admin_username must not be empty or contain spaces."
  }
}

variable "admin_ssh_public_key" {
  description = "Public SSH key for the VM administrator; never provide a private key."
  type        = string
}

variable "ssh_source_address_prefix" {
  description = "Optional trusted IPv4 CIDR allowed to SSH. Null disables SSH ingress."
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "Linux OS disk size in GB."
  type        = number
  default     = 30
}
