set :rails_env, "staging"
# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-005.vm.brightbox.net"
## List of servers
server "unepwcmc-005.vm.brightbox.net", :app, :web, :db, :primary => true
