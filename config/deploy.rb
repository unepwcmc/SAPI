# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'sapi'
set :repo_url, 'git@github.com:unepwcmc/SAPI.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_user, 'wcmc'
set :deploy_to, "/home/#{fetch(:deploy_user)}/#{fetch(:application)}"




# Default value for :scm is :git
set :scm, :git
set :scm_username, "unepwcmc-read"

# Default value for :format is :pretty
# set :format, :pretty


set :rvm_type, :user
set :rvm_ruby_version, '2.1.6'


# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true


set :ssh_options, {
  forward_agent: true,
}



# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/mailer_config.yml config/secrets.yml}

# Default value for linked_dirs is []
set :local_shared_dirs, %w('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/downloads', 'public/uploads','public/cites_trade_guidelines'}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

#require 'yaml'
#set :secrets, YAML.load(File.open('config/secrets.yml'))

#set :slack_token, secrets["development"]["capistrano_slack"] # comes from inbound webhook integration
#set :api_token, secrets["development"]["api_token"]
#set :slack_room, "#speciesplus" # the room to send the message to
#set :slack_subdomain, "wcmc" # if your subdomain is example.slack.com

# optional
#set :slack_application, "SAPI" # override Capistrano `application`
#deployment_animals = [
#  ["Loxodonta deployana", ":elephant:"],
#  ["Canis deployus", ":wolf:"],
#  ["Panthera capistranis", ":tiger:"],
#  ["Bison deployon", ":ox:"],
#  ["Ursus capistranus", ":bear:"],
#  ["Crotalus rattledeploy", ":snake:"],
#  ["Caiman assetocompilatus", ":crocodile:"]
#]

#set :shuffle_deployer, deployment_animals.shuffle.first

#set :slack_username, shuffle_deployer[0] # displayed as name of message sender
#set :slack_emoji, shuffle_deployer[1] # will be used as the avatar for the message


#namespace :seeds do
#  desc 'plants seeds, defined inside db/seeds.rb file'
#  task :plant, :roles => [:db] do
#    run "cd #{current_path} && RAILS_ENV=#{rails_env} rake db:seed"
#  end
#end


#namespace :import do

#  namespace :cleaned do
#    task :species, :roles => [:db] do
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned:species"
#    end
#    task :distributions, :roles => [:db] do
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned:distributions"
#    end
#    task :common_names, :roles => [:db] do
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned:common_names"
#    end
#    task :references, :roles => [:db] do
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned:references"
#    end
#    desc "Run full import"
#    task :all, :roles => [:db] do
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:cleaned"
#    end
#  end
#
#  desc "Redo full import (drop / create db, seeds, full import)"
#  task :redo, :roles => [:db] do
#    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake import:redo"
#  end
#end

#namespace :downloads do
#  namespace :cache do
#    desc "Clear cache"
#    task :clear, :roles => [:web, :app] do
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake downloads:cache:clear"
#    end

#    desc "Populate cache"
#    task :populate, :roles => [:web, :app] do
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake downloads:cache:update_species_downloads"
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake downloads:cache:update_checklist_downloads"
#    end

#    desc "Rotate cache"
#    task :rotate, :roles => [:web, :app] do
#      run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake downloads:cache:rotate"
#    end
#  end
#end



#namespace :deploy do
#  desc 'Rebuild database mviews'
#  task :rebuild, :roles => [:db] do
#    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate:rebuild"
#  end
#end
#after "deploy:rebuild", "downloads:cache:clear"



endpoints = [
  {
    name: "Species+",
    url: "http://www.speciesplus.net"
  },
  {
    name: "Public Trade",
    url: "http://trade.cites.org"
  },
  {
    name: "Private Trade",
    url: "http://www.speciesplus.net/trade"
  },
  {
    name: "Admin",
    url: "http://www.speciesplus.net/admin"
  }
]
set :urls_to_test, endpoints





task :smoke_test do

  message = ""

  urls = [
    "http://www.speciesplus.net", "http://trade.cites.org",
    "http://www.speciesplus.net/trade", "http://www.speciesplus.net/admin",
    "http://api.speciesplus.net/api/v1/taxon_concepts?name=Canis%20lupus",
    "http://api.speciesplus.net/api/v1/taxon_concepts/9644/references",
    "http://api.speciesplus.net/api/v1/taxon_concepts/9644/eu_legislation",
    "http://api.speciesplus.net/api/v1/taxon_concepts/9644/distributions",
    "http://api.speciesplus.net/api/v1/taxon_concepts/9644/cites_legislation"
  ]

  urls.each do |url|
    if /api/.match(url)
      curl_result = `curl -i -s -w "%{http_code}" #{url} -H "X-Authentication-Token:#{api_token}" -o /dev/null`
    else
      curl_result = `curl -s -w "%{http_code}" #{url} -o /dev/null`
    end

    if curl_result == "200"
      message << "#{url} passed the smoke test\n"
    elsif curl_result == "302"
      message << "#{url} passed the smoke test with a redirection\n"
    else
      message << "#{url} failed the smoke test\n"
    end
  end

  slack_smoke_notification message
end

def slack_smoke_notification message
  uri = URI.parse("https://hooks.slack.com/services/T028F7AGY/B036GEF7T/#{slack_token}")

  payload = {
    channel: slack_room,
    username: slack_username,
    text: message,
    icon_emoji: slack_emoji
  }

  response = nil

  request = Net::HTTP::Post.new(uri.request_uri)
  request.set_form_data({ :payload => JSON.generate( payload ) })

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  http.start do |h|
    response = h.request(request)
  end
end

after "deploy", "smoke_test"

