source 'https://rubygems.org'

gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'pg_array_parser'
gem 'activerecord-postgres-hstore'
#gem 'partitioned', :git => 'git@github.com:agnessa/partitioned.git'
gem 'json', '>=1.7.7'
gem 'foreigner'
gem 'oj'
gem 'jsonify'
gem 'inherited_resources'
gem 'traco'

gem 'sidekiq'
gem 'sidekiq-status'

gem 'whenever', :require => false

gem 'jquery-rails', '2.1.4' #do not upgrade until https://github.com/jquery/jquery/pull/1142 isd pulled into jquery-rails
gem 'bootstrap-generators', '~> 2.1'
gem 'kaminari'
gem 'select2-rails'
gem 'nested_form', '~> 0.3.1'
gem 'acts-as-taggable-on', '~> 2.3.1'

gem 'underscore-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'


# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :staging, :production do
  gem 'exception_notification', '=2.6.1', :require => 'exception_notifier'
  gem 'newrelic_rpm', '>=3.5.5'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'immigrant'
  gem "guard-livereload"
  gem "yajl-ruby"
  gem "rack-livereload"
  gem "guard-bundler"
  gem 'annotate', ">=2.5.0"
  gem 'sextant'
  gem 'ruby-debug19'
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'brightbox', '>=2.3.9'
  gem 'rack-cors', :require => 'rack/cors'
  gem 'quiet_assets'
  gem 'webrick', '1.3.1'
end

group :test, :development do
  gem "rspec-rails"
  gem "json_spec"
  gem "database_cleaner"
  gem "timecop"
end

group :test do
  gem "factory_girl_rails", "~> 4.0"
  gem 'simplecov', :require => false
end

gem 'rake', '~> 10.0.3'

gem 'slim'
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', '>= 1.3.0', :require => nil
