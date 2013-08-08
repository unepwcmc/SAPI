set :rails_env, "staging"
# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-012.vm.brightbox.net"
## List of servers
server "unepwcmc-012.vm.brightbox.net", :app, :web, :db, :primary => true
 
set :branch, "NewBrightboxDeploy"

set :application, "sapi"
set :server_name, "sapi.unepwcmc-012.vm.brightbox.net"
set :sudo_user, "rails"
set :app_port, "80" 

set :default_environment, {
  'PATH' => "/home/rails/.rvm/gems/ruby-1.9.2-p320/bin:/home/rails/.rvm/bin:/home/rails/.rvm/rubies/ruby-1.9.2-p320/bin:$PATH",
  'RUBY_VERSION' => 'ruby-1.9.2-p320',
  'GEM_HOME' => '/home/rails/.rvm/gems/ruby-1.9.2-p320',
  'GEM_PATH' => '/home/rails/.rvm/gems/ruby-1.9.2-p320',
}


namespace :deploy do
task :default do
update
assets.precompile
restart
cleanup
# etc
end
end
 
namespace :assets do
desc "Precompile assets locally and then rsync to app servers"
task :precompile, :only => { :primary => true } do
run_locally "bundle exec rake RAILS_ENV=staging assets:precompile;"
servers = find_servers :roles => [:app], :except => { :no_release => true }
servers.each do |server|
run_locally "rsync -av ./public/assets/ rails@unepwcmc-012.vm.brightbox.net:#{deploy_to}/shared/assets;"
end
run_locally "rm -rf public/assets"
run "ln -nfs #{deploy_to}/shared/assets #{deploy_to}/current/public/assets"
end
end





desc "Configure VHost"
task :config_vhost do
vhost_config =<<-EOF
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

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end



