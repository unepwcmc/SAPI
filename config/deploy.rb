set :default_stage, 'staging'

require 'capistrano/ext/multistage'
## Generated with 'brightbox' on 2013-06-27 08:45:55 +0100
gem 'brightbox', '>=2.3.9'
require 'brightbox/recipes'
require 'brightbox/passenger'
require 'sidekiq/capistrano'

set :generate_webserver_config, false
set :whenever_environment, defer { stage }
require 'whenever/capistrano'

require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3'

ssh_options[:forward_agent] = true

# The name of your application.  Used for deployment directory and filenames
# and Apache configs. Should be unique on the Brightbox
set :application, "sapi"


# got sick of "gem X not found in any of the sources" when using the default whenever recipe
# probable source of issue:
# https://github.com/javan/whenever/commit/7ae1009c31deb03c5db4a68f5fc99ea099ce5655
namespace :deploy do

  task :default do
    update
    assets.precompile
    restart
    cleanup
    # etc
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

end
 
namespace :assets do
  desc "Precompile assets locally and then rsync to app servers"
    task :precompile, :only => { :primary => true } do
    run_locally "bundle exec rake RAILS_ENV=staging assets:precompile;"
    servers = find_servers :roles => [:app], :except => { :no_release => true }
    servers.each do |server|
    run_locally "rsync -av ./public/assets/ rails@#{domain}:#{deploy_to}/shared/assets;"
    end
    run_locally "rm -rf public/assets"
    run "ln -nfs #{deploy_to}/shared/assets #{deploy_to}/current/public/assets"
  end
end


# Target directory for the application on the web and app servers.
set(:deploy_to) { File.join("", "home", user, application) }

# URL of your source repository. By default this will just upload
# the local directory.  You should probably change this if you use
# another repository, like git or subversion.

set :repository,  "git@github.com:unepwcmc/SAPI.git"
set :scm, :git
set :scm_username, "unepwcmc-read"
set :deploy_via, :remote_cache
set :copy_exclude, [ '.git' ]

### Other options you can set ##
# Comma separated list of additional domains for Apache
# set :domain_aliases, "www.example.com,dev.example.com"

## Dependencies
# Set the commands and gems that your application requires. e.g.
# depend :remote, :gem, "will_paginate", ">=2.2.2"
# depend :remote, :command, "brightbox"
#
# If you're using Bundler, then you don't need to specify your
# gems here as well as there (and the bundler gem is installed for
# you automatically)
#
# Gem with a source (such as github)
# depend :remote, :gem, "tmm1-amqp", ">=0.6.0", :source => "http://gems.github.com"
#
# Specify your specific Rails version if it is not vendored
# depend :remote, :gem, "rails", "=2.2.2"
#
# Set the apt packages your application or gems require. e.g.
# depend :remote, :apt, "libxml2-dev"

## Local Shared Area
# These are the list of files and directories that you want
# to share between the releases of your application on a particular
# server. It uses the same shared area as the log files.
#
# NOTE: local areas trump global areas, allowing you to have some
# servers using local assets if required.
#
# So if you have an 'upload' directory in public, add 'public/upload'
# to the :local_shared_dirs array.
# If you want to share the database.yml add 'config/database.yml'
# to the :local_shared_files array.
#
# The shared area is prepared with 'deploy:setup' and all the shared
# items are symlinked in when the code is updated.
set :local_shared_files, %w(config/database.yml)
set :local_shared_dirs, %w(tmp/pids public/downloads public/uploads
  public/downloads/cites_listings public/downloads/eu_listings public/downloads/cms_listings
  public/downloads/eu_decisions public/downloads/cites_suspensions public/downloads/quotas
  public/downloads/checklist public/downloads/taxon_concepts_names)

## Global Shared Area
# These are the list of files and directories that you want
# to share between all releases of your application across all servers.
# For it to work you need a directory on a network file server shared
# between all your servers. Specify the path to the root of that area
# in :global_shared_path. Defaults to the same value as :shared_path.
# set :global_shared_path, "/srv/share/myapp"
#
# NOTE: local areas trump global areas, allowing you to have some
# servers using local assets if required.
#
# Beyond that it is the same as the local shared area.
# So if you have an 'upload' directory in public, add 'public/upload'
# to the :global_shared_dirs array.
# If you want to share the database.yml add 'config/database.yml'
# to the :global_shared_files array.
#
# The shared area is prepared with 'deploy:setup' and all the shared
# items are symlinked in when the code is updated.
# set :global_shared_dirs, %w(public/upload)
# set :global_shared_files, %w(config/database.yml)

# SSL Certificates. If you specify an SSL certificate name then
# the gem will create an 'https' configuration for this application
# TODO: Upload and install the keys on the server
# set :ssl_certificate, "/path/to/certificate/for/my_app.crt"
# set :ssl_key, "/path/to/key/for/my_app.key
# or
# set :ssl_certificate, "name_of_installed_certificate"

## Static asset caching.
# By default static assets served directly by the web server are
# cached by the client web browser for 10 years, and cache invalidation
# of static assets is handled by the Rails helpers using asset
# timestamping.
# You may need to adjust this value if you have hard coded static
# assets, or other special cache requirements. The value is in seconds.
# set :max_age, 315360000

# SSH options. The forward agent option is used so that loopback logins
# with keys work properly
# ssh_options[:forward_agent] = true

# Forces a Pty so that svn+ssh repository access will work. You
# don't need this if you are using a different SCM system. Note that
# ptys stop shell startup scripts from running.
default_run_options[:pty] = true

## Logrotation
# Where the logs are stored. Defaults to <shared_path>/log
# set :log_dir, "central/log/path"
# The size at which to rotate a log. e.g 1G, 100M, 5M. Defaults to 100M
# set :log_max_size, "100M"
# How many old compressed logs to keep. Defaults to 10
# set :log_keep, "10"

## Version Control System
# Which version control system. Defaults to subversion if there is
# no 'set :scm' command.
# set :scm, :git
# set :scm_username, "rails"
# set :scm_password, "mysecret"
# or be explicit
# set :scm, :subversion

## Deployment settings
# The brightbox gem deploys as the user 'rails' by default and
# into the 'production' environment. You can change these as required.
# set :user, "rails"
# set :rails_env, :production

## Command running settings
# use_sudo is switched off by default so that commands are run
# directly as 'user' by the run command. If you switch on sudo
# make sure you set the :runner variable - which is the user the
# capistrano default tasks use to execute commands.
# NB. This just affects the default recipes unless you use the
# 'try_sudo' command to run your commands.
# set :use_sudo, false
# set :runner, user## Passenger Configuration
# Set the method of restarting passenger
# Defaults to :hard which is used to instantly free up database connections
# :soft uses the standard touch tmp/restart.txt which leaves database connections
# lingering until the workers time out
# set :passenger_restart_strategy, :hard

task :setup_production_database_configuration do
  the_host = Capistrano::CLI.ui.ask("Database IP address: ")
  database_name = Capistrano::CLI.ui.ask("Database name: ")
  database_user = Capistrano::CLI.ui.ask("Database username: ")
  pg_password = Capistrano::CLI.password_prompt("Database user password: ")

  require 'yaml'

  spec = {
    "#{rails_env}" => {
      "adapter" => "postgresql",
      "database" => database_name,
      "username" => database_user,
      "host" => the_host,
      "password" => pg_password
    }
  }

  run "mkdir -p #{shared_path}/config"
  put(spec.to_yaml, "#{shared_path}/config/database.yml")
end
after "deploy:setup", :setup_production_database_configuration

namespace :seeds do
  desc 'plants seeds, defined inside db/seeds.rb file'
  task :plant, :roles => [:db] do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} rake db:seed"
  end
end

namespace :import do

  namespace :cleaned do
    task :species, :roles => [:db] do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned:species"
    end
    task :distributions, :roles => [:db] do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned:distributions"
    end
    task :common_names, :roles => [:db] do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned:common_names"
    end
    task :references, :roles => [:db] do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned:references"
    end
  end

  desc "Run full import"
  task :cleaned, :roles => [:db] do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned"
  end

  desc "Redo full import (drop / create db, seeds, full import)"
  task :redo, :roles => [:db] do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:redo"
  end
end

namespace :downloads do
  namespace :cache do
    desc "Clear cache"
    task :clear, :roles => [:web, :app] do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake downloads:cache:clear"
    end

    desc "Populate cache"
    task :populate, :roles => [:web, :app] do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake downloads:cache:update_species_downloads"
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake downloads:cache:update_checklist_downloads"
    end

    desc "Rotate cache"
    task :rotate, :roles => [:web, :app] do
      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake downloads:cache:rotate"
    end
  end
end

namespace :deploy do
  desc 'Rebuild database mviews'
  task :rebuild, :roles => [:db] do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate:rebuild"
  end
end
after "deploy:rebuild", "downloads:cache:clear"
