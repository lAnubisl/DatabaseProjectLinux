# Install dotnet sdk 6.0
wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y dotnet-sdk-6.0

# Install SqlPackage
dotnet tool install -g microsoft.sqlpackage
export PATH="${PATH}:/root/.dotnet/tools"

# Install Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
sudo apt update && sudo apt install gpg
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform

# Install Azure CLI (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash