terraform {
  required_version = ">= 1.10"

  #state lives in a s3 bucket so everytime we retrieve the state before applying or deleting. 
  #That way we keep the infra versioned with the changes we make and I can delete it whenever I want.
  backend "s3" {
    bucket         = "jenkins-lab-tf-state"
    key            = "infra/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "jenkins-lab-tf-locks"
    use_lockfile = true
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

#credentials come from the AWS profile stored in SSO
provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project   = "jenkins-lab"
      ManagedBy = "terraform"
    }
  }
}