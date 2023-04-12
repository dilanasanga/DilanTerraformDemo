provider "azurerm" {
  features {}  
  }

terraform {
  required_providers {
    azurerm ={
        ssource = "hashicorp/azurerm"
        version = "3.51.0"
    }
  }
}

resource "azurerm_resource_group" "aks-rg" {
    name = "myResourceGroup"
    location = var.location
}

resource "azurerm_virtual_network" "aks-vnet" {
    name = "myVnet"
    address_space = "10.0.0.0/16"
    resource_group_name = azurerm_resource_group.aks-rg.name
    location = var.location

    subnet {
        name = "mySubnet"
        address_prefix = "10.0.0.0/24"
    } 
}

resource "azurerm_private_dns_zone" "aks-private-dns" {
    name = "AKSPrivateDNSZone"
    resource_group_name = azurerm_resource_group.aks-rg.name
}

resource "azurerm_container_registry" "aks-acr"{
    name = "AKSDemoACR"
    resource_group_name = azurerm_resource_group.aks-rg.name
    location = var.location
    sku = "Standard"
    admin_enabled = false
}

resource "azurerm_role_assignment" "role-acrpull" {
    scope = azurerm_container_registry.aks-acr.id
    role_definition_name = "AcrPull"
    skip_service_principal_aad_check = 
    principal_id = azurerm_kubernetes_cluster.aks-cluster.kublet_identity.0.object_id
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
    name = "AKSDemo"
    resource_group_name = azurerm_resource_group.aks-rg.name
    location = var.location
    kubernetes_version = var.kubernetes_version
    private_cluster_enabled = true


    default_node_pool {
      node_count = var.node_count
      vm_size = "Standard_D2s_v3"
      type = "VirtualMachine"
      name = "aks-nodepool"
      os_disk_size_gb = 100
      vnet_subnet_id = azurerm_virtual_network.aks-vnet.id
      enable_auto_scaling = false
    }
    identity {
        type = "SystemAssigned"
    }

    tags = {
      "Environment" = "Production"
      "Project" = "AKSDemo"
    }

}
