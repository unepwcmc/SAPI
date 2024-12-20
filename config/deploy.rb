# config valid only for current version of Capistrano
lock '3.18.0'

set :application, 'sapi'
set :repo_url, 'git@github.com:unepwcmc/SAPI.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_user, 'wcmc'
set :deploy_to, "/home/#{fetch(:deploy_user)}/#{fetch(:application)}"

set :backup_path, "/home/#{fetch(:deploy_user)}/Backup"

# Default value for :scm is :git
set :scm_username, 'unepwcmc-read'

# Default value for :format is :pretty
# set :format, :pretty

set :rvm_type, :user
set :rvm_ruby_version, '3.2.5'

# Sidekiq config
set :sidekiq_service_unit_user, :system
set :sidekiq_service_unit_name, 'sidekiq_sapi'

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

set :ssh_options, {
  keepalive: true,
  keepalive_interval: 60, # seconds
  forward_agent: true
}

# set :init_system, :systemd
# set :service_unit_name, "sidekiq_#{fetch(:application)}.service"

# Default value for :linked_files is []
# set :linked_files, %w{} - set config/{production,staging}.key in staging/production config

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/.well-known')
set :linked_dirs, fetch(:linked_dirs) + %w[public/uploads public/downloads private public/ID_manual_volumes]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

require 'yaml'
require 'json'

# snake_case to prevent injection
safe_stage = fetch(:stage).to_s.gsub(/\W+/, '_')
secrets = YAML.load(
  %x(bundle exec rails credentials:show -e #{safe_stage})
)

set :api_token, secrets['api_token'] # used in smoke testing

set :appsignal_config,
  push_api_key: secrets['appsignal_push_api_key'],
  active: true

set :slack_token, secrets['slack_exception_notification_webhook_url'] # comes from inbound webhook integration
set :slack_room, '#speciesplus' # the room to send the message to
set :slack_subdomain, 'wcmc' # if your subdomain is example.slack.com

# optional
set :slack_application, 'SAPI' # override Capistrano `application`
deployment_animals = [
  [ 'Loxodonta deployana', ':elephant:' ],
  [ 'Canis deployus', ':wolf:' ],
  [ 'Panthera capistranis', ':tiger:' ],
  [ 'Bison deployon', ':ox:' ],
  [ 'Ursus capistranus', ':bear:' ],
  [ 'Crotalus rattledeploy', ':snake:' ],
  [ 'Caiman assetocompilatus', ':crocodile:' ]
]

shuffle_deployer = deployment_animals.shuffle.first

set :slack_username, shuffle_deployer[0] # displayed as name of message sender
set :slack_emoji, shuffle_deployer[1] # will be used as the avatar for the message

# namespace :sidekiq do
# task :quiet do
#   on roles(:app) do
#     puts capture("pgrep -f 'sidekiq.*sapi' | xargs kill -TSTP")
#   end
# end
# task :restart do
#   on roles(:app) do
#     execute :sudo, :systemctl, :restart, :'sidekiq_sapi'
#   end
# end
# end

# after 'deploy:starting', 'sidekiq:quiet'
# after 'deploy:reverted', 'sidekiq:restart'
# after 'deploy:published', 'sidekiq:restart'

after 'deploy', 'smoke_test:test_endpoints'


require 'appsignal/capistrano'
