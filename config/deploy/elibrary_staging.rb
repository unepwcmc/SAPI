set :stage, :elibrary_staging
set :branch, "develop"

server "sapi-staging.linode.unep-wcmc.org", user: "wcmc", roles: %w{app web db}

set :domain, "sapi-staging.linode.unep-wcmc.org"

set :rails_env, "staging"

set :application, "elibrary"
set :deploy_to, "/home/#{fetch(:deploy_user)}/#{fetch(:application)}"

set :server_name, "#{fetch(:application)}.#{fetch(:domain)}"

set :sudo_user, "wcmc"

set :app_port, "80"