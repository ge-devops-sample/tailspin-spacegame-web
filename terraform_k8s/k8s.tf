resource "azurerm_resource_group" "k8s" {
    name     = var.resource_group_name
    location = var.location
}

resource "random_id" "suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.suffix.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = azurerm_resource_group.k8s.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.test.location
    resource_group_name   = azurerm_resource_group.k8s.name
    workspace_resource_id = azurerm_log_analytics_workspace.test.id
    workspace_name        = azurerm_log_analytics_workspace.test.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_container_registry" "acr" {
  name                     = "${var.acr_name}${random_id.suffix.dec}"
  resource_group_name      = azurerm_resource_group.k8s.name
  location                 = azurerm_resource_group.k8s.location
  sku                      = "Standard"
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.cluster_name}-${random_id.suffix.dec}"
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = var.dns_prefix

    #linux_profile {
    #    admin_username = "ubuntu"

    #    ssh_key {
    #        key_data = file(var.ssh_public_key)
    #    }
    #}

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_DS2_v2"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
        }
    }

    tags = {
        Environment = "Development"
    }
}

#resource "azurerm_role_assignment" "example" {
#  scope                = azurerm_container_registry.acr.id
#  role_definition_name = "acrpull"
#  principal_id         = azurerm_kubernetes_cluster.k8s.service_principal.0.client_id
#}
