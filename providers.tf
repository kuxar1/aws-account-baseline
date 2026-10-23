provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project    = "aws-account-baseline"
      ManagedBy  = "terraform"
      Repository = "github.com/kuxar1/aws-account-baseline"
    }
  }
}
