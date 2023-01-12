terraform {
  backend "s3" {
    bucket         = "iac-be-shared-terraform/"
    encrypt        = true
    key            = "teste-sg"
    region         = "us-west-2"
  }
}