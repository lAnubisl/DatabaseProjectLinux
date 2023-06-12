terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.45.0"
    }
  }
  required_version = ">= 1.4.6"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-my-database-project"
  location = "westeurope"
}

resource "azurerm_mssql_server" "mssql_server" {
  name                                 = "sql-my-database-deployment"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  version                              = "12.0"
  minimum_tls_version                  = "1.2"
  outbound_network_restriction_enabled = false
  public_network_access_enabled        = true
  azuread_administrator {
    login_username              = "InfrastructureDeployer"
    object_id                   = "00000000-0000-0000-0000-000000000000"
    azuread_authentication_only = true
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "db_guide" {
  name                 = "sqldb-my-database-deployment"
  server_id            = azurerm_mssql_server.mssql_server.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb          = 2
  sku_name             = "Basic"
  zone_redundant       = false
  ledger_enabled       = false
  storage_account_type = "Geo"
}

resource "azurerm_storage_account" "st_func" {
  name                            = "stfuncdotnetdbtest"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "func_plan" {
  name                = "plan-func-dotnet-db-test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "func" {
  name                       = "func-dotnet-db-test"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.st_func.name
  storage_account_access_key = azurerm_storage_account.st_func.primary_access_key
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "dotnet-isolated"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
  }
  site_config {
    ftps_state = "Disabled"
    application_stack {
      dotnet_version              = "6.0"
      use_dotnet_isolated_runtime = true
    }
  }
}