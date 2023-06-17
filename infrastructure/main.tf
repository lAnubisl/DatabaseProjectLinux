
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.45.0"
    }
  }
  required_version = ">= 1.4.6"
}

provider "azurerm" {
  features {}
}

# Configure variables
variable "SQL_server_AD_admin_login" {
  type        = string
  description = "The Active Directory login for the SQL Server AD administrator."
}

variable "SQL_server_AD_admin_object_id" {
  type        = string
  description = "The Active Directory object ID of the SQL Server AD administrator."
}

# Configure resources
resource "azurerm_resource_group" "rg" {
  name     = "rg-database-project-deployment"
  location = "westeurope"
}

resource "azurerm_mssql_server" "mssql_server" {
  name                                 = "sql-database-project-deployment"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  version                              = "12.0"
  minimum_tls_version                  = "1.2"
  outbound_network_restriction_enabled = false
  public_network_access_enabled        = true
  azuread_administrator {
    login_username              = var.SQL_server_AD_admin_login
    object_id                   = var.SQL_server_AD_admin_object_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "mssql_database" {
  name                 = "sqldb-database-project-deployment"
  server_id            = azurerm_mssql_server.mssql_server.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb          = 2
  sku_name             = "Basic"
  zone_redundant       = false
  ledger_enabled       = false
  storage_account_type = "Geo"
}