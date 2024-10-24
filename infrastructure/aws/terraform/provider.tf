terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.30.0"
   }
 }

 backend "s3" {
   region         = "ap-south-1"
   bucket         = "myportfolioinfrastructurebucket"
   key            = "my_portfolio_infrastructure_tfstate/terraform.tfstate"
 }
}