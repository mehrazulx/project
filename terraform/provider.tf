terraform {
  backend "s3" {
    bucket         = "mys3-privatelink"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "mys3-privatelink-tf-locks"
  }
}
