# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "echt" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    enviroment = "dev"
  }
}

# Create a virtuell network
resource "azurerm_virtual_network" "echt" {
  name                = "${var.prefix}-vn"
  resource_group_name = azurerm_resource_group.echt.name
  location            = azurerm_resource_group.echt.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    enviroment = "dev"
  }
}

# Create subnets

#Bar 10
resource "azurerm_subnet" "internal-bar" {
  name                 = "internal-bar"
  resource_group_name  = azurerm_resource_group.echt.name
  virtual_network_name = azurerm_virtual_network.echt.name
  address_prefixes     = ["10.0.10.0/24"]
}

#Shop 20
resource "azurerm_subnet" "internal-shop" {
  name                 = "internal-shop"
  resource_group_name  = azurerm_resource_group.echt.name
  virtual_network_name = azurerm_virtual_network.echt.name
  address_prefixes     = ["10.0.20.0/24"]
}

#EDV 30
resource "azurerm_subnet" "internal-edv" {
  name                 = "internal-edv"
  resource_group_name  = azurerm_resource_group.echt.name
  virtual_network_name = azurerm_virtual_network.echt.name
  address_prefixes     = ["10.0.30.0/24"]
}

#Event 40
resource "azurerm_subnet" "internal-event" {
  name                 = "internal-events"
  resource_group_name  = azurerm_resource_group.echt.name
  virtual_network_name = azurerm_virtual_network.echt.name
  address_prefixes     = ["10.0.40.0/24"]
}

#Management 99
resource "azurerm_subnet" "internal-mgmt" {
  name                 = "internal-management"
  resource_group_name  = azurerm_resource_group.echt.name
  virtual_network_name = azurerm_virtual_network.echt.name
  address_prefixes     = ["10.0.99.0/24"]
}

#Sever 100
resource "azurerm_subnet" "internal-sv" {
  name                 = "internal-server"
  resource_group_name  = azurerm_resource_group.echt.name
  virtual_network_name = azurerm_virtual_network.echt.name
  address_prefixes     = ["10.0.100.0/24"]
}


# Create Security-Group
resource "azurerm_network_security_group" "echt-sg" {
  name                = "echt-securitygroup"
  location            = azurerm_resource_group.echt.location
  resource_group_name = azurerm_resource_group.echt.name

  tags = {
    enviroment = "dev"
  }
}

# Inbound ruleset
resource "azurerm_network_security_rule" "echt-dev-rule" {
  name                        = "echt-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.echt.name
  network_security_group_name = azurerm_network_security_group.echt-sg.name
}

# Rule assigment to subnet
resource "azurerm_subnet_network_security_group_association" "echt-sga" {
  subnet_id                 = azurerm_subnet.internal-sv.id
  network_security_group_id = azurerm_network_security_group.echt-sg.id
}

# Create public IP
resource "azurerm_public_ip" "echt-ip" {
  name                = "echt-ip-1"
  resource_group_name = azurerm_resource_group.echt.name
  location            = azurerm_resource_group.echt.location
  allocation_method   = "Static"

  tags = {
    enviroment = "dev"
  }
}

# Create Interface on Subnet with public IP 
resource "azurerm_network_interface" "echt-nic" {
  name                = "echt-nic"
  location            = azurerm_resource_group.echt.location
  resource_group_name = azurerm_resource_group.echt.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal-sv.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.echt-ip.id
  }

  tags = {
    enviroment = "dev"
  }
}