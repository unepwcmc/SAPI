set :rails_env, "staging"
# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-012.vm.brightbox.net"
## List of servers
server "unepwcmc-012.vm.brightbox.net", :app, :web, :db, :primary => true

set :application, "sapi"
set :server_name, "sapi.unepwcmc-012.vm.brightbox.net"
set :sudo_user, "rails"
set :app_port, "80"

set :branch, :develop

desc "Configure VHost"
task :config_vhost do
  vhost_config = <<-EOF
    server {
      listen 80;
      client_max_body_size 4G;
      server_name #{application}.unepwcmc-012.vm.brightbox.net #{application}.sw02.matx.info;
      keepalive_timeout 5;
      root #{deploy_to}/current/public;
      passenger_enabled on;
      rails_env staging;

      add_header 'Access-Control-Allow-Origin' *;
      add_header 'Access-Control-Allow-Methods' "GET, POST, PUT, DELETE, OPTIONS";
      add_header 'Access-Control-Allow-Headers' "X-Requested-With, X-Prototype-Version";
      add_header 'Access-Control-Max-Age' 1728000;

      # Enable serving files through nginx
      passenger_set_cgi_param HTTP_X_ACCEL_MAPPING /home/rails/sapi/shared/public/downloads/=/downloads/;
      passenger_pass_header X-Accel-Redirect;

      location ~ ^/downloads/(.*)$ {
        alias /home/rails/sapi/shared/public/downloads/$1;
        internal;
      }

      gzip on;
      location ^~ /assets/ {
        expires max;
        add_header Cache-Control public;
      }

      if (-f $document_root/system/maintenance.html) {
        return 503;
      }

      error_page 500 502 504 /500.html;
      location = /500.html {
        root #{deploy_to}/public;
      }

      error_page 503 @maintenance;
      location @maintenance {
        rewrite  ^(.*)$  /system/maintenance.html break;
      }
    }
  EOF
  put vhost_config, "/tmp/vhost_config"
  sudo "mv /tmp/vhost_config /etc/nginx/sites-available/#{application}"
  sudo "ln -s /etc/nginx/sites-available/#{application} /etc/nginx/sites-enabled/#{application}"
end

after "deploy:setup", :config_vhost
