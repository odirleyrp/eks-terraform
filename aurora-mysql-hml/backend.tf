terraform {
  backend "s3" {
    bucket  = "iac-be-shared-terraform/"
    encrypt = true
    key     = "bbce-homologa/ehub-rds-aurora-homologa"
    region  = "us-west-2"
  }
}