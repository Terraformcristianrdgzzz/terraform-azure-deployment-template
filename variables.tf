variable "resource_group_name" {
  description = "Existing resource group where network and web server resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region for the deployment."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "IPv4 CIDR address spaces for the virtual network."
  type        = list(string)
}

variable "subnet_name" {
  description = "Name of the web server subnet."
  type        = string
}

variable "subnet_prefixes" {
  description = "IPv4 CIDR prefixes for the web server subnet."
  type        = list(string)
}

variable "vm_name" {
  description = "Name of the Linux virtual machine."
  type        = string
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string
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
