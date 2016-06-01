# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'sapi'
set :repo_url, 'git@github.com:unepwcmc/SAPI.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_user, 'wcmc'
set :deploy_to, "/home/#{fetch(:deploy_user)}/#{fetch(:application)}"

set :backup_path, "/home/#{fetch(:deploy_user)}/Backup"

# Default value for :scm is :git
set :scm, :git
set :scm_username, "unepwcmc-read"

# Default value for :format is :pretty
# set :format, :pretty

set :rvm_type, :user
set :rvm_ruby_version, '2.2.3'

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

set :ssh_options, {
  forward_agent: true,
}

before "deploy:symlink:shared", "rsync:sync"

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/mailer_config.yml config/secrets.yml .env}

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle')
set :linked_dirs, fetch(:linked_dirs) + %w{public/uploads public/downloads private}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

# clear the previous precompile task
Rake::Task["deploy:assets:precompile"].clear_actions
class PrecompileRequired < StandardError; end

namespace :deploy do
  namespace :assets do
    desc "Precompile assets"
    task :precompile do
      on roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            begin
              # find the most recent release
              latest_release = capture(:ls, '-xr', releases_path).split[1]

              # precompile if this is the first deploy
              raise PrecompileRequired unless latest_release

              latest_release_path = releases_path.join(latest_release)

              # precompile if the previous deploy failed to finish precompiling
              execute(:ls, latest_release_path.join('assets_manifest_backup')) rescue raise(PrecompileRequired)

              fetch(:assets_dependencies).each do |dep|
                # execute raises if there is a diff
                execute(:diff, '-Naur', release_path.join(dep), latest_release_path.join(dep)) rescue raise(PrecompileRequired)
              end

              info("Skipping asset precompile, no asset diff found")

              # copy over all of the assets from the last release
              execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_path.join('public', fetch(:assets_prefix)))
            rescue PrecompileRequired
              execute(:rake, "assets:precompile")
            end
          end
        end
      end
    end
  end
end

require 'yaml'
require 'json'
secrets =  YAML.load(File.open('config/secrets.yml'))

set :slack_token, secrets["development"]["capistrano_slack"] # comes from inbound webhook integration
set :api_token, secrets["development"]["api_token"]
set :slack_room, "#speciesplus" # the room to send the message to
set :slack_subdomain, "wcmc" # if your subdomain is example.slack.com

#optional
set :slack_application, "SAPI" # override Capistrano `application`
deployment_animals = [
  ["Loxodonta deployana", ":elephant:"],
  ["Canis deployus", ":wolf:"],
  ["Panthera capistranis", ":tiger:"],
  ["Bison deployon", ":ox:"],
  ["Ursus capistranus", ":bear:"],
  ["Crotalus rattledeploy", ":snake:"],
  ["Caiman assetocompilatus", ":crocodile:"]
]

shuffle_deployer = deployment_animals.shuffle.first

set :slack_username, shuffle_deployer[0] # displayed as name of message sender
set :slack_emoji, shuffle_deployer[1] # will be used as the avatar for the message

after "deploy", "smoke_test:test_endpoints"

require 'appsignal/capistrano'
