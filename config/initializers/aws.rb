Aws.eager_autoload!(services: %w(S3 EC2))

access_key_id = Rails.application.secrets.aws['access_key_id']
secret_access_key = Rails.application.secrets.aws['secret_access_key']


Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(access_key_id, secret_access_key)
})

