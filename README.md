# A quick intro to the repo
An iac project that launch the infrastructure over aws for two different regions based on the workspace and variable file
please go to the [lab screens](https://docs.google.com/document/d/1WQ7ELbRqgRS5PszK29fZzIDdnI_PQK6wtzIc3RuQCek/edit) for more visuals and screenshots to the project
## What does it have? 
The project uses variable files to deploy two different workspaces using the variable files into two different regions in aws by that we also state the different availability zones while creating subnets. The lab is divided into 11 steps we will go throw as follows

## Steps

### 1- Creating two different workspaces

we create the workspaces in terraform to store our states for each environment. the code to create the workspace is `terraform workspace new "workspace_name"` . just copy the command and replace with the workspace name you desire

to navigate or checkout to this workspace you created use the following command `terraform workspace select "workspace_name"`

to view all workspaces you currently have in the project use the following command `terraform workspace list`

### 2- Add your variable files
for this project we just used two files that contain two different variables for each workspace: `dev.tfvars` and
`prod.tfvars`

for this project we just used two files that contain two different variables for each workspace: `dev.tfvars` and `prod.tfvars`

> [!WARNING]
> Just try to make sure you have the `variables.tf` file that contains the definition for the variables we have in the `*.tfvars`.
> if you dint have it you will get an error **Undeclared Variable**

In this project we used variables, for example, in `provider.tf` that connects to AWS to create my infrastructure.
we used variables like :
```
region          = "us-east-1"
instance_type   = "t2.micro"
```
we reference  the variable as in `provider.tf` file as `region = var.region`

### 3- Creating local network module

`network_module` holds the declaration of my network in the infrastructure like _VPC - Subnets- InternetGateway_

using the module we need to do two steps:
- creating `network_module.tf` file that holds the usage and the path of the module. the content of the file as follows :
```
source                = "./network"
vpc_cidr              = var.vpc_cidr
```
the variables here are the variables we declared before to send to the variables in the module. the module itself have `variables.tf` so we need to send them over the module if we need to use.
- creating `output.tf` file in the module that says how we need to access the resources in the module. the file contnet is:
```
output vpc_id {
  value       = aws_vpc.your_vpc_name.id
}
```
then we use this output in the file as `vpc_id      = module.network_module.vpc_id`

### 4- Apply the changes

> [!NOTE]
> Just make sure you change workspace before applying terraform changes to make sure the state is not over written by the other variable file.

to apply the changes, first make sure the resources will be created successfully by running `terraform plan -var-file="your_var_file.tfvars"`
if everything is good you will see at the end of the output for the command something like `+10 to be added +0 to be changed +0 to be destroyed `

apply the changes to your cloud provided by running `terraform apply -var-file="your_var_file.tfvars"`

> [!NOTE]
> the flag we used `-var-file=` is an option we pass to terraform to use a variable file. you might not use the flag if you have defaults in the `variables.tf` file. yet it is a good practice to use different var files to customize the variables to the environment you will use


