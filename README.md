# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Project Overview
For this project, I will have the opportunity to demonstrate the skills I've learned in this course, by creating infrastructure as code in the form of a Terraform template to deploy a website with a load balancer.  I am assuming my company has created an application that needs to be deployed to Azure. The application is self-contained, but it need to be deployed customised based on specifications provided at build time, with an eye towards scaling the application for use in a CI/CD pipeline. Due to high costs of the PaaS it will be deployed using IaaS as cost control. It will also be deployed across multiple virtual machines since its anticipated that it will be a popular service. Inorder to minimise snd support work, Packer will be used create a server image and Terraform to create a template for deploying a scalable cluster of servers- with a load balancer to manage the incoming traffic. I will also adhere to security practices and ensure that my infrastructure is secure.

### A Summary of the project's main steps

1. Creating a Packer template
2. Creating a Terraform template
3. Deploying the infrastructure
4. Creating documentation in the form of a README

### Packer template
In order to support application deployment, I will need to create a customisable image that can the utilised by different organisations to deploy their own apps! To achieve this, I'll create a packer image that anyone can use, following the instructions provided at [Azure documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer).To build an image, I create a template as a JSON file. In the template, I defined ``builders`` and ``provisioners`` that carry out the actual build process. Packer has a provisioner for Azure that allowed me to define Azure resources, such as the service principal credentials [az ad sp create-for-rbac](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest).
 ###Example of template with builders and provisioners:
``{
  "builders": [{
    "type": "azure-arm",
    [...]
  "provisioners": [{
    "inline": ["echo 'Hello, World!' > index.html",
    "nohup busybox httpd -f -p 80 &" ],
    [...]
    ],``
This template builds an Ubuntu 18.04 LTS SKU. The image is built by specifying the Packer template file as follows:
``./packer build server.json``

The output is as  follows:
``azure-arm output will be in this color.

==> azure-arm: Running builder ...
    azure-arm: Creating Azure Resource Manager (ARM) client ...
==> azure-arm: Creating resource group ...
==> azure-arm:  -> ResourceGroupName : ‘packer-Resource-Group-swtxmqm7ly’
==> azure-arm:  -> Location          : ‘UK South’
==> azure-arm:  -> Tags              :
[...]
ManagedImageResourceGroupName: myResourceGroup
ManagedImageName: myPackerImage
ManagedImageLocation: uksouth``
The process takes a few minutes to build the VM, run the provisioners, and clean up the deployment.


### Terraform template
[Terraform](https://www.terraform.io/) is a provisioning tool that creates infrastructure according to a configuration file that one creates. This file can be saved and reused.
It uses a domain specific language, known as HashiCorp Language or HCL to interface with all of the major cloud providers on all major operating systems.
The Terraform template will allow me to create, update, and destroy the created infrastructure. To get started I used ``terraform init`` and to view the resource that would be created, I used ``terraform plan``. To apply my plan and deploy my infrastructure I used ``terraform apply``. And make sure that the new infrastructure has been created , I used ``terraform show``. Lastly, to take down the infrastructure I used ``terraform destroy``.

Before we get started, we'll need to verify that the policy we deployed in an earlier lesson (that one that requires tags) is still available using the Azure CLI, and include a screenshot of that policy output in our repository.

### Specific instructions

1. Customizing and scaling the webserver
- The variable ``num_of_vms`` is set to default as 2 at [variable.tf](). It is scalable, thus feel free to change the number as per your requirement.
      - The variable ``num_of_vms`` is set to default as 2 at [variable.tf](https://github.com/corneyc/nd082-Azure-Cloud-DevOps-Starter-Code/blob/master/C1%20-%20Azure%20Infrastructure%20Operations/project/starter_files/terraform/variables.tf). It is scalable, thus feel free to change the number as per your requirement.
      - Other variables like ``packer_image_name``,``packer_resource_group``,``tags``,``resource_group``,``location`` can also be configured in this [variable.tf] file

2. Create and deploy a policy definition to deny the creation of resources that donot have tags
      - Create the Azure policy definition by running the shell script ``create_az_policy_definition.sh``
      - Assign the policy definition using the Azure portal
      - Verify the created policy via the Azure CLI using the command ``az policy assignment list``

3. Create a server image using packer
      - Create an image resource group named PolicyRG by ``az group create --location south UK --name PolicyRG``
      - Use the required fields in packer template file   [webserver.json](https://github.com/arunprakashpj/Udacity-Azure-Cloud-DevOps/blob/master/C1%20-%20Azure%20Infrastructure%20Operations/project/starter_files/Packer/webserver.json)  
      - Build the packer image using the command ``packer build webserver.json``
      - Use ``az image list`` to list out the images present
      - Use ``az image delete -g packer-rg -n myPackerImage`` to delete any existing packer image

4. Create the infrastructure using terraform
      - Create a terraform file  [main.tf](https://github.com/corneyc/nd082-Azure-Cloud-DevOps-Starter-Code/blob/master/C1%20-%20Azure%20Infrastructure%20Operations/project/starter_files/terraform/main.tf) and [variable.tf](https://github.com/corneyc/nd082-Azure-Cloud-DevOps-Starter-Code/blob/master/C1%20-%20Azure%20Infrastructure%20Operations/project/starter_files/terraform/variables.tf)
      - Create a Resource Group
      - Create a virtual network and a subnet on the virtual network
      - Create a Network Security Group
      - Create a Network Interface
      - Create a Public IP
      - Create a Load Balancer
      - Create a virtual machine availability set
      - Create virtual machines. Make sure you use the image you deployed using packer
      - Create managed disks for your virtual machines
      - Ensure declarative configuration is possible by using  [variable.tf](https://github.com/corneyc/nd082-Azure-Cloud-DevOps-Starter-Code/blob/master/C1%20-%20Azure%20Infrastructure%20Operations/project/starter_files/terraform/variables.tf) file

 5. Deploy all Azure resources
      - Initialise the terraform using the command ``terraform init``
      - See the plan by using the command ``terraform plan -out solution.plan``
      - Apply the deployment using ``terraform apply``

 6. Deploy all Azure resources
      - Destroy all the resources created by terraform using the command ``terraform destroy``
      - Destroy the image built by the packer using the command ``az image delete -g PolicyRG -n myServerImage``


### Output
1. [Packer image](https://github.com/corneyc/nd082-Azure-Cloud-DevOps-Starter-Code/blob/master/C1%20-%20Azure%20Infrastructure%20Operations/project/starter_files/Packer/packerImage.png)

2. [Policy template](https://github.com/corneyc/nd082-Azure-Cloud-DevOps-Starter-Code/blob/master/C1%20-%20Azure%20Infrastructure%20Operations/project/starter_files/Packer/policy_template.png)

3. [Tagging policy](https://github.com/corneyc/nd082-Azure-Cloud-DevOps-Starter-Code/blob/master/C1%20-%20Azure%20Infrastructure%20Operations/project/starter_files/Taggingpolicy/Tagging-Policy_screen.png)
