namespace :config do
  task :setup do
    ask(:db_user, 'db_user')
    ask(:db_pass, 'db_pass')
    ask(:db_name, 'db_name')
    # ask(:db_host, 'db_host')
    setup_config = <<-EOF
#{fetch(:rails_env)}:
  adapter: postgresql
  database: #{fetch(:db_name)}
  username: #{fetch(:db_user)}
  password: #{fetch(:db_pass)}
  socket: /var/run/postgresql/.s.PGSQL.5432
#  host: #{fetch(:db_host)}
EOF
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(setup_config), "#{shared_path}/config/database.yml"
    end
  end
end

namespace :config do
  task :setup do

    vhost_config = <<-EOF

server {
  listen 80;
  client_max_body_size 4G;
  server_name #{fetch(:server_name)};

  keepalive_timeout 5;
  root #{deploy_to}/current/public;

  location ^~ /sidekiq {
    passenger_enabled on;
    rails_env production;
    auth_basic "Restricted Admin Area";
    auth_basic_user_file #{deploy_to}/shared/.htpasswd;
  }

  passenger_enabled on;

  passenger_set_header X-Sendfile-Type "X-Accel-Redirect";
  passenger_env_var X-Sendfile-Type "X-Accel-Redirect";
  passenger_env_var X-Accel-Mapping "/home/#{fetch(:deploy_user)}/#{fetch(:application)}/shared/public/downloads/=/downloads/";
  passenger_pass_header X-Accel-Redirect;
  passenger_pass_header X-Sendfile-Type;

  passenger_ruby /home/#{fetch(:deploy_user)}/.rvm/gems/ruby-#{fetch(:rvm_ruby_version)}/wrappers/ruby;

  location ~ ^/downloads/(.*)$ {
    alias #{deploy_to}/shared/public/downloads/$1;
    internal;
  }

  rails_env #{fetch(:rails_env)};

  add_header 'Access-Control-Allow-Origin' *;
  add_header 'Access-Control-Allow-Methods' "GET, POST, PUT, DELETE, OPTIONS";
  add_header 'Access-Control-Allow-Headers' "X-Requested-With, X-Prototype-Version";
  add_header 'Access-Control-Max-Age' 1728000;

  gzip on;
  location ~ ^/assets/ {
    root #{deploy_to}/current/public;
    expires max;
    add_header Cache-Control public;
    add_header ETag "";
    break;
  }

  error_page 503 @503;

  # Return a 503 error if the maintenance page exists.
  if (-f #{deploy_to}shared/public/system/maintenance.html) {
    return 503;
  }

  location @503 {
    # Serve static assets if found.
    if (-f $request_filename) {
      break;
    }

    # Set root to the shared directory.
    root #{deploy_to}/shared/public;
    rewrite ^(.*)$ /system/maintenance.html break;
  }
}
EOF

    on roles(:app) do
      execute "sudo mkdir -p /etc/nginx/sites-available"
      upload! StringIO.new(vhost_config), "/tmp/vhost_config"
      execute "sudo mv /tmp/vhost_config /etc/nginx/sites-available/#{fetch(:application)}"
      execute "sudo ln -s /etc/nginx/sites-available/#{fetch(:application)} /etc/nginx/sites-enabled/#{fetch(:application)}"
    end
  end
end

namespace :config do
  task :setup do
    ask(:s3_access_key_id, 's3_access_key_id')
    ask(:s3_secret_access_key, 's3_secret_access_key')
    ask(:s3_bucket, 's3_bucket')
    ask(:mail_server, 'mail_server')
    backup_config_db = <<-EOF
#  encoding: utf-8
##
# Backup Generated: sapi_website
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t sapi_website [-c <path_to_configuration_file>]
#
Model.new(:sapi_website_db, 'sapi_website_db') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  # split_into_chunks_of 250
  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = "#{fetch(:db_name)}"
    db.username           = "#{fetch(:db_user)}"
    db.password           = "#{fetch(:db_pass)}"
    db.host               = "#{fetch(:db_host)}"
    db.port               = 5432
    db.socket             = "/var/run/postgresql/"
    # When dumping all databases, `skip_tables` and `only_tables` are ignored.
    #db.skip_tables        = ["skip", "these", "tables"]
    #db.only_tables        = ["only", "these", "tables"]
    #db.additional_options = ["-xc", "-E=utf8"]
  end
  ##
  # Amazon Simple Storage Service [Storage]
  #
  # See the documentation on the Wiki for details.
  # https://github.com/meskyanichi/backup/wiki/Storages
  store_with S3 do |s3|
   # AWS Credentials
    s3.access_key_id     = "#{fetch(:s3_access_key_id)}"
    s3.secret_access_key = "#{fetch(:s3_secret_access_key)}"
    # Or, to use a IAM Profile:
    # s3.use_iam_profile = true
    s3.region            = "us-east-1"
    s3.bucket            = "#{fetch(:s3_bucket)}"
    s3.path              = "/db"
  end
  ##
  # Bzip2 [Compressor]
  #
  compress_with Bzip2
##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the Wiki for other delivery options.
  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true
    mail.from                 = "#{fetch(:smtp_user)}"
    mail.to                   = "stuart.watson@unep-wcmc.org"
    mail.address              = "#{fetch(:mail_server)}"
    mail.port                 = 587
    mail.domain               = "your.host.name"
    mail.user_name            = "#{fetch(:smtp_user)}"
    mail.password             = "#{fetch(:smtp_password)}"
    mail.authentication       = "login"
    mail.encryption           = :starttls
  end
 end
EOF

    on roles(:db) do
      execute "mkdir -p #{fetch(:backup_path)}/models"
      upload! StringIO.new(backup_config_db), "#{fetch(:backup_path)}/models/db_#{fetch(:application)}.rb"
    end
  end
end

namespace :config do
  task :setup do
    backup_config_files = <<-EOF
# encoding: utf-8
# Backup Generated: sapi_files
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t sapi_files [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://meskyanichi.github.io/backup
#
Model.new(:sapi_files, 'sapi_files') do
  ##
  # Amazon Simple Storage Service [Storage]
  #
  store_with S3 do |s3|
    # AWS Credentials
    s3.access_key_id     = "#{fetch(:s3_access_key_id)}"
    s3.secret_access_key = "#{fetch(:s3_secret_access_key)}"
    # Or, to use a IAM Profile:
    # s3.use_iam_profile = true
    s3.region            = "us-east-1"
    s3.bucket            = "#{fetch(:s3_bucket)}"
    s3.path              = "/files"
end
 archive :app_archive do |archive|
 archive.add '"#{shared_path}/system/public/uploads'
end
 ##
  # Bzip2 [Compressor]
  #
  compress_with Bzip2
 ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the Wiki for other delivery options.
  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true
    mail.from                 = "#{fetch(:smtp_user)}"
   mail.to                   = "stuart.watson@unep-wcmc.org"
    mail.address              = "#{fetch(:mail_server)}"
    mail.port                 = 587
    mail.domain               = "your.host.name"
    mail.user_name            = "#{fetch(:smtp_user)}"
    mail.password             = "#{fetch(:smtp_password)}"
    mail.authentication       = "login"
    mail.encryption           = :starttls
  end
end
EOF

    on roles(:app) do
      execute "mkdir -p #{fetch(:backup_path)}/models"
      upload! StringIO.new(backup_config_files), "#{fetch(:backup_path)}/models/files_#{fetch(:application)}.rb"
    end
  end
end

namespace :config do
  task :setup do
    on roles(:app, :db) do
      execute "/bin/bash -l -c '/home/#{fetch(:deploy_user)}/.rvm/gems/ruby-2.1.3/bin/backup generate:config'"
    end
  end
end

namespace :config do
  task :setup do
    backup_schedule = <<-EOF
every 1.day, :at => '11:30 pm' do
  command "backup perform -t sapi_files"
  command "backup perform -t sapi_website_db"
end
EOF

    on roles(:db) do
      execute "mkdir -p #{fetch(:backup_path)}/config"
      upload! StringIO.new(backup_schedule), "#{fetch(:backup_path)}/config/#{fetch(:application)}-schedule.rb"
    end
  end
end

namespace :config do
  task :setup do
    desc "Upload cron schedule file."
    task :upload_cron do
      execute "mkdir -p #{fetch(:backup_path)}/config"
      execute "touch #{fetch(:backup_path)}/config/cron.log"
      upload! StringIO.new(File.read("config/backup/schedule.rb")), "#{fetch(:backup_path)}/config/#{fetch(:application)}-schedule.rb"
    end
  end
end

namespace :config do
  desc "Update crontab with whenever"
  task :setup do
    on roles(:app, :db) do
      execute "cd '#{fetch(:backup_path)}' && /bin/bash -l -c '/home/#{fetch(:deploy_user)}/.rvm/gems/ruby-2.1.3/bin/whenever -f config/#{fetch(:application)}-schedule.rb --update-crontab'"
    end
  end
end

namespace :config do
  desc "Configure app specific nagios monitoring"
  task :setup do
    on roles(:app) do
      execute "echo command[check_procs_redis]=/usr/lib/nagios/plugins/check_procs -c 1:3000 -C redis-server | sudo tee -a /etc/nagios/nrpe.cfg"
      execute "echo command[check_sapi_sidekiq]=/usr/lib/nagios/plugins/check_file_exists #{shared_path}/tmp/pids/sidekiq.pid | sudo tee -a /etc/nagios/nrpe.cfg"
      execute "echo command[restart-sapi-sidekiq]=/usr/lib/nagios/plugins/restart-sapi-sidekiq #{shared_path}/tmp/pids/sidekiq.pid | sudo tee -a /etc/nagios/nrpe.cfg"
    end
  end
end

namespace :config do
  desc "Configure app specific event handler"
  task :setup do
    nagios_config = <<-EOF
cd #{deploy_to}/current/ ; nohup bundle exec sidekiq -e production -C #{deploy_to}/current/config/sidekiq.yml -i 0 -P #{shared_path}/tmp/pids/sidekiq.pid >> #{deploy_to}/current/log/sidekiq.log 2>&1 &
  EOF
    on roles(:app) do
      upload! StringIO.new(nagios_config), "/tmp/nagios_config"
      execute "sudo mv /tmp/nagios_config /usr/lib/nagios/plugins/restart-sapi-sidekiq"
      execute "chmod a+x /usr/lib/nagios/plugins/restart-sapi-sidekiq"
    end
  end
end

namespace :config do
  desc "Configure logrotate"
  task :setup do
    logrotate_config = <<-EOF
#{deploy_to}/current/log/*.log {
  monthly
  missingok
  rotate 12
  compress
  delaycompress
  notifempty
  copytruncate
}
  EOF
    on roles(:app) do
      upload! StringIO.new(logrotate_config), "/tmp/logrotate_config"
      execute "sudo mv /tmp/logrotate_config /etc/logrotate.d/#{fetch(:application)}-logs"
    end
  end
end
