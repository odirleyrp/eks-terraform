output user_app-liza {
  value = [
    module.user_liza.arn,
    module.user_liza.access_key,
    module.user_liza.secret_key,
  ]
}

output s3 {
  value = [
    module.s3_liza.id,
    module.s3_liza.arn,
    ]
}