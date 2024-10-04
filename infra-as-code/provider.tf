terraform {
    required_providers {
        aws = {
            version = " >4.9.0"
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "eu-north-1"
    # profile = "default"
}