# A quick intro to the repo
An iac project that launch the infrastructure over aws for two different regions based on the workspace and variable file
please go to the [lab screens](https://docs.google.com/document/d/1WQ7ELbRqgRS5PszK29fZzIDdnI_PQK6wtzIc3RuQCek/edit) for more visuals and screenshots to the project
## What does it have? 
The project uses variable files to deploy two different workspaces using the variable files into two different regions in aws by that we also state the different availability zones while creating subnets. The lab is divided into 10 steps we will go throw as follows

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
- creating `output.tf` file in the module that says how we need to access the resources in the module. the file content is:
```
output vpc_id {
  value       = aws_vpc.your_vpc_name.id
}
```
then we use this output in the file as `vpc_id      = module.network_module.vpc_id`

### 4- Apply the changes

> [!NOTE]
> Just make sure you change workspace before applying terraform changes to make sure the state is not overwritten by the other variable file.

to apply the changes, first make sure the resources will be created successfully by running `terraform plan -var-file="your_var_file.tfvars"`
if everything is good you will see at the end of the output for the command something like `+10 to be added +0 to be changed +0 to be destroyed `

apply the changes to your cloud provided by running `terraform apply -var-file="your_var_file.tfvars"`

> [!NOTE]
> the flag we used `-var-file=` is an option we pass to terraform to use a variable file. you might not use the flag if you have defaults in the `variables.tf` file. yet it is a good practice to use different var files to customise the variables to the environment you will use

### 5- adding provisioner 

we edit the instance a little to add a provisioner so we can have access to the data that is being created in the cloud provider. we have a simple example which is the use of `local-exec` to print the ip the instance will have. Than, we use this output to add in a file called `inventory` file. the importance of this file is we can use ansible code to write an automation script with ansible after creating the instance. Think of this as we want to install apache and curl on the instances we will create.
Use the following command to obtain such a thing:
```
 provisioner "local-exec" {
    command = "echo ${self.public_ip} > inventory"
  }
```

`local-exec` is the type of the provisioner and `self` refer to the instance that is being created.

### 6- Create a Docker Image that has Jenkins installed and Terraform to run the commands

The Dockerfile is so simple
```
FROM jenkins/jenkins:latest # this is the image that has all prerequisites to run Jenkins Server

USER root

RUN apt-get update && apt-get install -y curl unzip # installation of curl and update all packages

# commands to download and install terraform and then clean up 
RUN curl -LO https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip && \
    unzip terraform_1.5.7_linux_amd64.zip -d /usr/local/bin/ && \
    rm terraform_1.5.7_linux_amd64.zip

USER jenkins
```
to build the docker image use : `docker -t build "created_image:some_tag" . `

don't forget to map ports from the docker container to your local host by running the following docker command

`docker run -d -p 8080:8080 -p 50000:50000 --name "container_name" "created_image"`
port `8080` is the port of Jenkins while port `50000` is terraform port

### 7- Create Env Parameters and Pipeline

To create the parameters just add the following line in Jenkins pipeline:
```
parameters {
  choice(name: 'server', choices: ["Development", "Production"], description: 'Select environment')
}
```
this will help us later while creating the workspaces and installing of terraform infrastructure based on the selection. 

then write your Jenkins code to create pipeline to get the code from your repo and validate the code by running `terraform plan -var-file="*.tfvars"` and if success, run `terraform apply -var-file="*.tfvars"`

> [!NOTE]
> Don't forget to create another pipeline  to clear the infrastructure if you are learning so you are not charged while not using the services you created.
> you can simply get rid of this by running the following commands
> ```
> terraform destroy -var-file=*.tfvars
> terraform workspace select default
> terraform workspace delete "workspace_name"
> ```
### 8- Verify Email on AWS

to send emails from your email to any email address from your account, go to SES servers on AWS, Simple Email Service. Then add your email and verify from your mailbox.
after verifying the email address, head to authorization in SES in AWS and make sure your email is authorized to send emails by adding sendEmails Policy.

### 9- Create AWS Lambda Function

create a lambda function to send emails whenever there is a change in our s3-bucket that holds the state files 
```
import boto3

def lambda_handler(event, context):
    ses = boto3.client('ses', region_name='eu-central-1')
    sender_email = 'sender_email@example.com'
    recipient_email = 'recipient_email@example.com'
    subject = 'email_subject'
    body = "email_body"
    response = ses.send_email(
        Source=sender_email,  
        Destination={
            'ToAddresses': [
                recipient_email,
            ],
        },
        Message={
            'Subject': {
                'Data': subject,
            },
            'Body': {
                'Text': {
                    'Data': body,
                },
            },
        },
    )

    return {
        'statusCode': 200,
        'body': 'Email sent successfully.',
    }
```

> [!NOTE]
> Don't forget to give lambda the permission to access the s3 resources.

### 10- Create Trigger

now all the prerequisites  are completed. Yet one step to be added. we create a trigger to fire whenever the state change and send emails right after.
in our case, we have the s3 bucket. Head to properties and add event notification, and select ***PUT*** and ***POST*** then select lambda function to run whenever the state changes

## Done
after completing all the steps above, now you are ready to send emails when you run the pipeline from jenkins that fetches code from our github.
dont forget to keep learning 😉
Happy DevOps'ing' 😄🚀
