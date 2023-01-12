locals {
  common_tags  = {
    ambiente                 = "hml"
    app                      = "goliza"
    modalidade               = "sustentacao"
    terraform                = true
  }
}



module s3_liza {
  source        = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/bucket-s3"
  s3_name       = "goliza-hml"
  s3_versioning = false
  s3_policy     = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${module.user_liza.arn}"
            },
            "Action": "*",
            "Resource": [
                "${module.s3_liza.arn}/*",
                "${module.s3_liza.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${module.s3_liza.arn}/*",
                "${module.s3_liza.arn}"
            ]
        }
    ]
}
POLICY
  s3_tags = merge(local.common_tags)
}
