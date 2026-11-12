mock_provider "azurerm" {
  mock_resource "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    }
  }

  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test"
    }
  }

  mock_resource "azurerm_public_ip" {
    defaults = {
      id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/vm-test-pip"
      ip_address = "198.51.100.10"
    }
  }

  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/vm-test-nsg"
    }
  }

  mock_resource "azurerm_network_interface" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/vm-test-nic"
      private_ip_address = "10.10.1.4"
    }
  }

  mock_resource "azurerm_network_interface_security_group_association" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/vm-test-nic"
    }
  }

  mock_resource "azurerm_linux_virtual_machine" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/virtualMachines/vm-test"
    }
  }

  mock_resource "azurerm_network_security_rule" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/vm-test-nsg/securityRules/ssh"
    }
  }
}

variables {
  resource_group_name  = "rg-test"
  location             = "East US"
  vnet_name            = "vnet-test"
  vnet_address_space   = ["10.10.0.0/16"]
  subnet_name          = "snet-test"
  subnet_prefixes      = ["10.10.1.0/24"]
  vm_name              = "vm-test"
  admin_username       = "azureuser"
  admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYRfcekcBMIMpQre6Xi3IM2SZmBgIRqT/ihJ4DgkNwE terraform-test-only"
}

run "composes_network_and_webserver" {
  command = apply

  assert {
    condition     = output.vm_name == "vm-test"
    error_message = "The composed deployment must expose the configured VM name."
  }

  assert {
    condition     = output.public_ip_address == "198.51.100.10"
    error_message = "The composed deployment must expose the web server public IP."
  }

  assert {
    condition     = output.website_url == "http://198.51.100.10"
    error_message = "The composed deployment must expose the website URL."
  }
}
