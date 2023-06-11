terraform {
  backend "s3" {
    bucket  = "nurrfz-terraform-backend"
	  key     = "terraform.tfstate"
	  encrypt = true
	  region  = "eu-central-1"
    
  }
  }

