# Integration Platform automation on AWS
## Infrastructure Overview  
![architecture](assets/integration-platform.jpg)


**NOTE:** the following instruction works under linux and windows

## 0. Prerequisites 

**Create AWS iam user/group with the following permissions:**
1. AmazonEC2FullAccess
2. AmazonVPCFullAccess 
3. AmazonRoute53FullAccess
4. AmazonElasticFileSystemFullAccess
5. AmazonS3FullAccess

**Download terraform**
https://www.terraform.io/downloads.html

The terraform configs created for the version 0.11.x

## 1. Generate your deployer key pair:  
go into the project root directory and generate the deployer-key and public ssh cert

or put into `.ssh` folder your own key and public part for it

```
ssh-keygen -t rsa -f ./.ssh/deployer-key
```

This key you could use to connect bastion server 

## 2. Create terraform workspace (dev/stage/prod)
go into the directory `terraform/aws`
```
cd terraform/aws
terraform workspace new dev
```

## 3. Define AWS credentials
Create file `1.auto.tfvars` with content:
```
aws_access_key = "Here put your access_key"
aws_secret_key = "Here put your secret_key"
## the following key will be used as a token to access kubernetes. change it.
deployer_token = "1234567890-1234567890-1234567890-1234567890"
```  
Actually the file should match `*.auto.tfvars` to be loaded automatically.

## 4. Initialize terraform
The following command verifies your `*.tf` configuration and initializes your workspace according to it.
```
terraform init
```
## 5. Deploy Integration Platform
This command compares local configuration with current state and suggests changes to be applied. Type `yes` when asked.
```
terraform apply
```
  
## 6. Certificate  

We are using self-signed certificate  for Application LoadBalancer.
It is signed with custom CA certificate. So, to make server certificate valid for your brawser/mobile import the following file into the truststore:

`certificates/ca.docker.local.cer`

details in [certificates/README.md](./certificates/README.md)
