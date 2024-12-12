## How to create Virtual Machine for application ?
1. Set up your Azure subscription
2. Generate SSH key
```bash 
ssh-keygen -t rsa -b 4096 -f ~/.ssh/seeai -C "seeai"
```

2. Use Terraform (**Infrastructure as Code**) to deploy application to Azure (a cloud platform)


```bash 
terraform init
terraform plan
terraform apply
```


## How to clean up (delete) resources ?

```bash
terraform plan --destroy
terraform destroy
```