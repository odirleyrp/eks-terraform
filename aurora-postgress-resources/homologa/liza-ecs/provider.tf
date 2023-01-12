provider "aws" {
  region  = "us-west-2"
  version = "~> 2.0"

assume_role {

role_arn = "arn:aws:iam::993324252386:role/Admin_AssumeRole"

}
}
