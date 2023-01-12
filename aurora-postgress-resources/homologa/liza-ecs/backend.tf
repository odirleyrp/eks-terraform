terraform {
  backend "s3" {
    bucket  = "iac-be-shared-terraform"
    key     = "projeto-lisa-hml/ecs-goliza-web"
    region  = "us-west-2"
    encrypt = true
  }
}

