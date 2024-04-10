aws_region = Rails.application.secrets.aws[:region]
access_key_id = Rails.application.secrets.aws[:access_key_id]
secret_access_key = Rails.application.secrets.aws[:secret_access_key]

Aws.config.update({
  region: aws_region,
  credentials: Aws::Credentials.new(access_key_id, secret_access_key)
})
