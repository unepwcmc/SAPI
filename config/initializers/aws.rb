aws_region = Rails.application.credentials.dig(:aws, :region)
access_key_id = Rails.application.credentials.dig(:aws, :access_key_id)
secret_access_key = Rails.application.credentials.dig(:aws, :secret_access_key)

Aws.config.update({
  region: aws_region,
  credentials: Aws::Credentials.new(access_key_id, secret_access_key)
})
