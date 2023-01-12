terraform {
  backend "s3" {
    bucket  = "iac-be-shared-terraform"
    key     = "projeto-goliza-hml/goliza-alb-tg-hml"
    region  = "us-west-2"
    encrypt = true
  }
}