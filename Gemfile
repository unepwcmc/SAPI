source 'https://rubygems.org'

gem 'rails', '4.0.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg', '~> 0.20.0'
gem 'actionpack-action_caching'
gem 'activerecord-postgres-hstore'
gem 'active_model_serializers', '~> 0.8.4'
gem 'activeresource'
gem 'activeuuid', '>= 0.5.0'
gem 'dalli'
gem 'pg_array_parser'
gem 'protected_attributes'
gem 'nested-hstore'
gem 'pg_search', '~> 0.5.7'
gem 'foreigner'
gem 'oj' # optimised JSON (picked by multi_json)
gem 'nokogiri', '>= 1.6.7.2'
gem 'inherited_resources'
gem 'traco', '~> 2.0.0'
gem 'devise', '>= 3.5.4'
gem 'cancan'
gem 'ahoy_matey'
gem 'gon'
gem 'wicked'
gem 'groupdate'
gem "chartkick"
gem 'rubyzip', '>= 1.0.0'
gem 'rails-observers'

gem 'sidekiq', '< 5'
gem 'sidekiq-status'
gem 'sidekiq-unique-jobs', '5.0.10'# , git: 'git://github.com/mhenrixon/sidekiq-unique-jobs'

gem 'redis-rails'

gem 'whenever', :require => false

gem 'ember-rails'
gem 'ember-source', '1.1.2'
gem 'jquery-rails', '2.1.4' # do not upgrade until https://github.com/jquery/jquery/pull/1142 isd pulled into jquery-rails
gem 'jquery-mousewheel-rails'
gem 'jquery-cookie-rails'
gem 'bootstrap-sass', '~> 2.3.1.0'
gem 'kaminari'
gem 'select2-rails', '~> 3.5.7'
gem 'nested_form', '~> 0.3.2'
gem 'acts-as-taggable-on', '~> 2.4.1'
gem 'carrierwave'

gem 'underscore-rails'
gem "font-awesome-rails"

gem 'aws-sdk', '~> 2'

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
#
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby
#
gem 'uglifier', '>= 1.0.3'
gem "susy"
gem 'compass', '>= 0.12.2'
gem 'compass-rails', '>= 1.0.3'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'rest-client', require: false

group :development do
  gem "better_errors", '~>1.1.0'
  gem "binding_of_caller", '>=0.7.2'
  gem 'immigrant'
  gem "guard-livereload"
  gem "yajl-ruby"
  gem "rack-livereload"
  gem "guard-bundler"
  gem 'annotate', ">=2.5.0"
  gem 'sextant'
  # Deploy with Capistrano
  gem 'capistrano', '~> 3.11.0', require: false
  gem 'capistrano-rails',   '~> 1.4.0', require: false
  gem 'capistrano-bundler', '~> 1.5.0', require: false
  gem 'capistrano-rvm', '~> 0.1.2', require: false
  gem 'capistrano-maintenance', '~> 1.0', require: false
  gem 'capistrano-passenger', '~> 0.2.0', require: false
  gem 'capistrano-local-precompile', '~> 1.2.0', require: false
  gem 'slackistrano', require: false
  gem 'brightbox', '>=2.3.9'
  gem 'rack-cors', :require => 'rack/cors'
  gem 'quiet_assets'
  gem 'webrick', '1.3.1'
  gem 'jslint_on_rails'
  gem 'git_pretty_accept'
  gem 'rubocop', '~> 0.40.0', require: false
  gem 'letter_opener'
end

group :test, :development do
  gem "rspec-rails", '~> 2.14.0'
  gem "rspec-mocks", '~> 2.14.0'
  gem "json_spec", '~> 1.1.1'
  gem "database_cleaner", ">=1.2.0"
  gem "timecop"
  gem "launchy"
  gem 'byebug'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem "factory_girl_rails", "~> 4.0"
  gem 'simplecov', :require => false
  gem 'coveralls', :require => false
  gem 'capybara'
end

gem 'rake', '~> 10.0.3'

gem 'slim'
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', '>= 1.3.0', :require => nil

gem 'memcache-client'

gem 'jquery-ui-rails'

gem 'geoip'

# track who created or edited a given object
gem 'clerk'
gem 'paper_trail', '~> 4.0'
gem 'request_store', '~> 1.1'

gem 'rails-secrets'
gem 'dotenv-rails'

gem 'sitemap_generator'

gem 'appsignal'
gem 'test-unit', '~> 3.1' # annoyingly, rails console won't start without it in staging / production
