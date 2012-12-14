source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'pg_array_parser'
gem 'activerecord-postgres-hstore'
#gem 'partitioned', :git => 'git@github.com:agnessa/partitioned.git'
gem 'awesome_nested_set'
gem 'foreigner'
gem 'oj'
gem 'jsonify'
gem 'inherited_resources'
gem 'traco'

gem 'sidekiq'
gem 'sidekiq-status'

gem 'whenever', :require => false

gem 'jquery-rails'
gem 'bootstrap-generators', '~> 2.1'
gem 'bootstrap-editable-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

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
  gem 'exception_notification', :require => 'exception_notifier'
  gem 'newrelic_rpm', '>=3.5.3.25'
end

group :development do
  gem 'immigrant'
  gem "guard-livereload"
  gem "yajl-ruby"
  gem "rack-livereload"
  gem "guard-bundler"
  gem 'annotate', ">=2.5.0"
  gem 'ruby-debug19'
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'brightbox', '>=2.3.9'
  gem 'rack-cors', :require => 'rack/cors'
end

group :test, :development do
  gem "rspec-rails"
  gem "database_cleaner"
end

group :test do
  gem "factory_girl_rails", "~> 4.0"
  gem 'simplecov', :require => false
end
