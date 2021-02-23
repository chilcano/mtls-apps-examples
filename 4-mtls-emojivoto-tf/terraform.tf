provider "aws" {
  region = var.region
}

/*
terraform {
  backend "remote" {
    organization = "Smallstep"

    workspaces {
      name = "Emojivoto"
    }
  }
}
*/