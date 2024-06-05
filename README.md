# Terraform Cloud Project
## Project Demo for Terraform Cloud
>[!Note]
>## Tools Used
>VSCode, Github, Terraform, Terraform Cloud

>[!Tip]
>## Execution Path
>Manifest File -> PUSH -> Github -> PUSH -> Terraform Cloud -> Organisation -> Run -> AWS Cloud

## Manifest File : Contains providers, resources and variables
Github -> SCM containts Terraform project and HCL Script 
Terraform Cloud -> Cloud IAAC management with version control. Creating Organisation
Organisation -> Different workspace for Dev, QA, Stagin, Production, Deliver and DR

## Basic
1. Install Terraform, Github on either remote server or local machine
2. Create a terraform manifest file to create 4 ec2-instance with ubuntu version
3. Make sure 2 public and 2 private servers, nat gateway, internet gateway , subnets and private table

## Github 
1. Create a new public repository with .gitignore as terraform
2. Copy all tf files and push to origin

## Terraform Cloud
1. Search Terraform Cloud and pick the official link
2. Create a free account -> Confirm email -> Create Organisation -> Create Workspace
a. Version Control Workflow - Git based workspace
b. CLI-Driver - CLI Based
c. API-Driver - Application based like VSCode
3. We are using Version Control -> Github -> Authorise -> Select the repo -> Confirm 
4. Get into the workspace -> Configure variables or left side pane Variables 
a. Add Variable -> Environment -> ```AWS_ACCESS_KEY_ID(key) -> account access key(value)```
b. Add Variable -> Environment -> ```AWS_SECRET_ACCESS_KEY(key) -> account secret access key(value)```
5. Start Plan -> Check for ```terraform plan``` results -> if okay -> Confirm & Apply -> to perform ```terraform apply —auto -approve```
6. After Successful Run -> TFSTATE file will be there in left pane -> States
7. We will generate state files for each run. So we can download older versions of state files
8. Top Right -> Lock -> to lock state files when concurrent access requests appear
9. Sentinel Policies (Paid)
a. it will deny the unauthorised users (who try to change public/private sources, stealing info, deleting stuffs)
b. Key Management Services
c. This will start securing resources during creation itself (ignore_changes life-cycle only secure resources after creation)
10. Make a small change in resource -> push to origin git -> wait for terraform cloud to catch the change and start execution
11. Left Side Pane -> Settings -> Destruction & Deletion 
a. Destruction - Delete all the resources created by the terraform in the workspace
b. Delete - Delete all the resources, variables, settings in the workspace and delete workspace too

[! Important]
## This project has no state file and it wont directly work using fork
