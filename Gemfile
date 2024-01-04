source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '4.1.16'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'actionpack-action_caching', '1.2.0'
gem 'actionpack-page_caching', '1.1.1'
gem 'active_model_serializers', '0.8.4'
gem 'activeresource', '4.1.0'
gem 'dalli', '2.7.10'
gem 'pg', '0.17.1'
gem 'activeuuid', '0.6.1' # TODO: should remove when upgrade to Rails 6.
gem 'pg_array_parser', '0.0.9'
# gem 'activerecord-postgres-hstore'
gem 'nested-hstore', '0.0.5'
gem 'pg_search', '0.6.4'
gem 'foreigner', '1.5.0'
gem 'oj', '2.15.0' # optimised JSON (picked by multi_json)
gem 'nokogiri', '1.10.3'
gem 'inherited_resources', '1.7.2' # TODO: need upgrade when upgrade to Rails 5
gem 'traco', '2.0.0'
# gem 'strong_parameters'
gem 'protected_attributes', '1.1.4' # TODO: Only support Rails version < 5 (https://github.com/rails/protected_attributes)
gem 'devise', '4.0.0'
gem 'cancan', '1.6.10'
gem 'ahoy_matey', '1.0.1'
gem 'gon', '5.2.0'
gem 'wicked', '1.3.3'
gem 'groupdate', '2.4.0'
gem "chartkick", '1.3.2'
gem 'rubyzip', '1.1.7'

gem 'sidekiq', '4.1.1'
gem 'sidekiq-status', '0.6.0'
gem 'sidekiq-unique-jobs', '4.0.18'
gem 'redis-rails', '4.0.0'

gem 'whenever', '0.9.4', :require => false
gem 'httparty', '0.16.2'

gem 'sprockets', '2.12.5' # upgrading to 3 breaks handlebars/tilt
gem 'ember-rails', '0.14.1'
gem 'ember-source', '1.6.1'
gem 'ember-data-source', '0.14'
gem 'handlebars-source', '1.0.12'
gem 'jquery-rails', '2.1.4' # do not upgrade until https://github.com/jquery/jquery/pull/1142 isd pulled into jquery-rails
gem 'jquery-mousewheel-rails', '0.0.9'
gem 'jquery-cookie-rails', '1.3.1.1'
gem 'bootstrap-sass', '2.3.2.2'
gem 'kaminari', '1.2.2'
gem 'select2-rails', '3.5.10' #initSelection deprecated on upgrade to version 4
gem 'nested_form', '0.3.2'
gem 'acts-as-taggable-on', '4.0.0'
gem 'carrierwave', '0.10.0'
gem 'prawn', '0.13.2'
gem 'pdfkit', '0.8.4.2'
gem 'wkhtmltopdf-binary', '0.9.9.3'

gem 'underscore-rails', '1.4.3'
gem "font-awesome-rails", '4.5.0.1'

gem 'aws-sdk', '~> 2'
gem 'rails-observers', '0.1.5' # TODO: a feature that removed since Rails 4...

# Gems used for assets
gem 'sass-rails',   '5.0.7'
gem 'coffee-rails', '4.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '2.7.2'
gem 'susy', '2.2.14'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'rest-client', '1.8.0', require: false

group :development do
  gem "better_errors", '1.1.0'
  gem 'immigrant', '0.1.4'
  gem "guard-livereload", '1.1.3'
  gem "yajl-ruby", '1.1.0'
  gem "rack-livereload", '0.3.11'
  gem "guard-bundler", '1.0.0'
  gem 'annotate', "2.5.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
	gem 'spring' # TODO: upgrade when upgrade Ruby/Rails.
  # gem 'sextant'
  # Deploy with Capistrano
  gem 'capistrano', '3.11.0', require: false
  gem 'capistrano-rails',   '1.4.0', require: false
  gem 'capistrano-bundler', '1.5.0', require: false
  gem 'capistrano-rvm', '0.1.2', require: false
  gem 'capistrano-maintenance', '1.0.0', require: false
  gem 'capistrano-passenger', '0.2.0', require: false
  gem 'capistrano-local-precompile', '1.2.0', require: false
  gem 'capistrano-sidekiq', '1.0.2'
  gem 'slackistrano', '0.1.9', require: false
  gem 'brightbox', '2.3.9'
  gem 'rack-cors', '0.3.0' ,:require => 'rack/cors' # TODO: remove when upgrade Rails.
  gem 'quiet_assets', '1.1.0'
  gem 'webrick', '1.3.1'
  gem 'jslint_on_rails', '1.1.1'
  gem 'rubocop', '0.40.0', require: false
  gem 'rbnacl', '4.0.2'
  gem 'rbnacl-libsodium', '1.0.16'
  gem 'bcrypt_pbkdf', '1.1.0'
  gem 'ed25519', '1.2.4'
  # @TODO: bring back when ruby updated to > 2.6 # gem 'net-ssh', '7.0.0.beta1' # openssl 3.0 compatibility @see https://stackoverflow.com/q/72068406/1090438
end

group :test, :development do
  gem "rspec-rails", '3.0.2'
  gem 'rspec-collection_matchers', '1.1.3'
  gem "rspec-mocks", '3.0.4'
  gem "json_spec", '1.1.5'
  gem "database_cleaner", "1.2.0" # TODO, should remove after upgrade Rails.
  gem "timecop", '0.6.3'
  gem "launchy", '2.4.3'
  gem 'byebug', '3.2.0'
end

group :test do
  gem "codeclimate-test-reporter", '0.1.1', require: nil # TODO, should be removed
  gem "factory_girl_rails", '4.2.1'
  gem 'simplecov', '0.9.1', :require => false
  gem 'coveralls', '0.7.1', :require => false
  gem 'capybara', '2.2.1'
end

gem 'rake', '10.0.4'

gem 'slim', '1.3.6'
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', '1.3.5', :require => nil

gem 'memcache-client', '1.8.5'

gem 'jquery-ui-rails', '4.1.2'

gem 'geoip', '1.3.5'

# track who created or edited a given object
gem 'clerk', '0.2.2'
gem 'paper_trail', '4.2.0'
gem 'request_store', '1.3.2'

gem 'dotenv-rails', '2.0.1'

gem 'sitemap_generator', '5.1.0'

gem 'appsignal', '1.3.3'
gem 'test-unit', '3.1.5' # annoyingly, rails console won't start without it in staging / production
