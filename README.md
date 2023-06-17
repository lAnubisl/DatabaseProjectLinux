# Environment Setup
## Description

This is a sample repository that shows how to create SQL Database on Azure and deploy database schema to it.
The full article can be found here [https://byalexblog.net/article/azure-sql-schema-deployment/](https://byalexblog.net/article/azure-sql-schema-deployment/)


## 1. Install dotnet6. See: https://learn.microsoft.com/en-us/dotnet/core/install/linux-debian (later versions are not supported by sqlpackage as of 1 Jub 2023)
``` 
wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y dotnet-sdk-6.0
```

## 2. Install SqlPackage. See: https://github.com/microsoft/DacFx
```
dotnet tool install -g microsoft.sqlpackage
export PATH="$PATH:/home/codespace/.dotnet/tools"
```


## 3. Install Terraform. See: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
sudo apt update && sudo apt install gpg
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform
```

## 4. Install Database Project Template
```
dotnet new -i Microsoft.Build.Sql.Templates
```

# Project

## 1. Create new project
```
dotnet new sqlproj -n ProductsTutorial
```

## 2. Add database entities (tables)
```
cd ProductsTutorial/

echo -e "CREATE TABLE dbo.Item ( \n\
    Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, \n\
    Name NVARCHAR(100) NOT NULL, \n\
    Price DECIMAL(18,2) NOT NULL \n\
);" > dbo.Item.sql

dotnet build --configuration Release
cd ..
```

# Indrastructure deployment
```
cd infrastructure
terraform init -var-file="input.tfvars"

az login --tenant 00000000-0000-0000-0000-000000000000 --use-device-code
az account set --subscription 00000000-0000-0000-0000-000000000000

terraform apply -var-file="input.tfvars"
cd ..
```

# Database Project deployment
```
token=$(az account get-access-token --resource=https://database.windows.net/ --query accessToken --output tsv)

sqlpackage \
    /Action:Publish \
    /SourceFile:"bin/Release/ProductsTutorial.dacpac" \
    /AccessToken:$token \
    /TargetConnectionString:"Server=sql-database-project-deployment.database.windows.net; Encrypt=True; Database=sqldb-database-project-deployment;"
```