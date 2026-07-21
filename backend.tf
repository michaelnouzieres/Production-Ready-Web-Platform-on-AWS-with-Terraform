terraform {
  backend "s3" {
    bucket = "amrock-tfstate-bucket"
    key    = "wordpress/prod/terraform.tfstate"
    region = "us-east-1"

    use_lockfile = true

    encrypt = true
  }
}