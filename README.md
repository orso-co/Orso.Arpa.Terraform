# Orso.Arpa.Terraform

To use the terraform cli on the repo you have to change the current directory to `terraform\azure`

## Init

`terraform init`

## Plan

`terraform plan -out infra.plan`

## Apply 

`terraform apply infra.plan`

## Update documentation

`terraform-docs markdown --footer-from docs/footer.md --header-from docs/header.md . > README.md`

## Run test

`go test`

## naming convention

use modules from <https://github.com/gsoft-inc/terraform-azurerm-naming>

## format code

`terraform fmt`