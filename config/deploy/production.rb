set :rails_env, "production"
# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-004.vm.brightbox.net"
## List of servers
#server "unepwcmc-004.vm.brightbox.net", :app, :web, :db, :primary => true

role :web, "unepwcmc-004.vm.brightbox.net"
role :app, "unepwcmc-004.vm.brightbox.net"
role :db, "unepwcmc-009.vm.brightbox.net", :primary => true
