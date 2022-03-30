# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Install an editor like vscode for highlight syntax, this is OPTIONAL, we can use notepad instead
2. Open terminal
3. Login azure cli with command line: az login
4. Add env viriables ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID to your computer. Depend on your OS you will have different ways to add env variables.
6. exec new policy with command line: az policy definition create --name <name of policy> -- rules plicy.json
7. Init packer with command line: packer init
8. Update managed_image_resource_group_name in server.json file. Use the name of group resource you have created.
9. Build package image using command line: packer build server.json
9. Using command "az image list" to check image image created in step above
10. Go to Azure portal to get packer image Id, and replace value of ariable "packerImageId" in variables.tf 
11. To be using terraform, run command line: terraform init
12. Run "terraform plan" to view resources that will be create
13. Run "terraform apply" to deploy your infrastructure
14. Run "terraform show" to see your new infrastructure
15. Run "terraform destroy" to destroy your infrastructure if you need
  
  
### Output
We have new resources:
  - Linux machine image: myPackerImage
  - udacity-terraform-network
  - udacity-terraform-subnet
  - udacity-terraform-nic_1
  - udacity-terraform-nic_2
  - udacity-terraform-public_ip
  - udacity-terraform-avset
  - udacity-terraform-vm_1
  - udacity-terraform-vm_2
  - udacity-terraform-disk1_1
  - udacity-terraform-disk1_2
  - udacity-terraform-lb
  - azurerm_lb_probe: ssh-running-probe
  - azurerm_lb_rule: http

