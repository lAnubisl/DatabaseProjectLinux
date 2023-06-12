
applicationId="00000000-0000-0000-0000-000000000000"
secretValue="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tenatnId="00000000-0000-0000-0000-000000000000"
subscriptionId="00000000-0000-0000-0000-000000000000"

az login --service-principal -u $applicationId -p $secretValue --tenant $tenatnId
az account set --subscription $subscriptionId

# Deploy Infrastructure
cd Infrastructure
terraform init
terraform plan -out out.plan -input=false
terraform apply out.plan -auto-approve -input=false
cd ..

# Assign the database System Assigned Managed Identity to the 'Directory Readers' Azure AD Role
# https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-directory-readers-role?view=azuresql#assigning-the-directory-readers-role

# Build the database project
dotnet build MyDatabaseProject/MyDatabaseProject.sqlproj

# Deploy the project
token=$(az account get-access-token --resource=https://database.windows.net/ --query accessToken --output tsv)
serverName="sql-my-database-deployment"
databaseName="sqldb-my-database-deployment"
sqlpackage \
    /Action:Publish \
    /SourceFile:"MyDatabaseProject/bin/Debug/MyDatabaseProject.dacpac" \
    /AccessToken:$token \
    /TargetConnectionString:"Server=$serverName.database.windows.net; Encrypt=True; Database=$databaseName;"