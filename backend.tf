terraform {
  backend "s3" {
    bucket       = "devopsing-tfstate-882386995952"
    key          = "aws-account-baseline/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}
