require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']

source 'https://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'rails-api'

gem 'pg'
gem 'foreigner'
gem 'immigrant'
gem 'awesome_nested_set'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'


# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

guard_notifications = true
group :development do
  case HOST_OS
  when /darwin/i
    gem 'rb-fsevent'
    gem 'ruby_gntp' if guard_notifications
  when /linux/i
    gem 'libnotify'
    gem 'rb-inotify'
  when /mswin|windows/i
    gem 'rb-fchange'
    gem 'win32console'
    gem 'rb-notifu' if guard_notifications
  end
end

group :development do
  gem "guard-livereload"
  gem "yajl-ruby"
  gem "rack-livereload"
  gem "guard-bundler"
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
  gem 'ruby-debug19'
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'brightbox', '>=2.3.9'
end

gem "sqlite3", :group => [:test]

group :test, :development do
  gem "rspec-rails"
  gem "factory_girl"
end
