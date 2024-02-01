source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.6.1'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# https://stackoverflow.com/questions/55213868/rails-6-how-to-disable-webpack-and-use-sprockets-instead
gem 'sprockets', '3.7.2'
gem 'sprockets-rails', :require => 'sprockets/railtie'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem 'actionpack-action_caching', '~> 1.2', '>= 1.2.2' # A feature that removed from core in Rails 4.0, maybe be better migrate away from this.
gem 'actionpack-page_caching', '~> 1.2', '>= 1.2.4' # A feature that removed from core in Rails 4.0, maybe be better migrate away from this.
gem 'active_model_serializers', '0.8.4' # Deprecated
gem 'dalli', '2.7.10' # TODO: latest is 3.2.6. I believe should be fine to upgrade but we have no way to test.
gem 'pg', '~> 1.5', '>= 1.5.4'
gem 'pg_array_parser', '~> 0.0.9'
gem 'nested-hstore', '~> 0.1.2'
gem 'pg_search', '~> 2.3', '>= 2.3.6'
gem 'oj', '~> 3.16', '>= 3.16.3' # optimised JSON (picked by multi_json)
gem 'inherited_resources', '~> 1.14' # Deprecated (https://github.com/activeadmin/inherited_resources#notice)
gem 'nokogiri', '1.15.5' # TODO: New version need Ruby 3
gem 'mobility', '~> 1.2', '>= 1.2.9'
gem 'devise', '4.7.3' # TODO: need upgrade to 4.8+ when upgrade to rails 6.1
gem 'cancancan', '~> 3.5'
gem 'ahoy_matey', '4.2.1' # TODO: latest 5.0.2. Can't upgrade to 5.0 until upgrade to Rails 6.1
gem 'uuidtools', '~> 2.2' # For Ahoy. (https://github.com/ankane/ahoy/blob/v2.2.1/docs/Ahoy-2-Upgrade.md#activerecordstore)

# TODO: starting from v1.4, it break our test due to redirection changes:
#   rspec ./spec/controllers/admin/nomenclature_changes/lump_controller_spec.rb:147
#   rspec ./spec/controllers/admin/nomenclature_changes/split_controller_spec.rb:191
gem 'wicked', '1.3.4'

gem 'groupdate', '6.2.1' # TODO: can upgrade after rails 6.1 and newer ruby 3

gem 'rubyzip', '~> 2.3', '>= 2.3.2'
gem 'responders', '~> 3.1', '>= 3.1.1' # https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders

gem 'sidekiq', '< 7' # TODO, latest is 7
gem 'sidekiq-status', '~> 3.0', '>= 3.0.3'
gem 'sidekiq-unique-jobs', '7.1.31' # TODO: can upgrade to latest when sidekiq upgrade to 7
gem 'sidekiq-cron', '~> 1.12'

gem 'httparty', '~> 0.21.0'

gem 'kaminari', '~> 1.2', '>= 1.2.2' # TODO: Suggest migrate to pagy gem.

gem 'acts-as-taggable-on', '9.0.1' # TODO: latest v10 @ 2023. Can upgrade after upgrade to Rails 6.1
gem 'carrierwave', '2.2.5' # TODO: latest is 3.0.5 @ 2023. can upgrade to v3 after Rails 6

# PDF
gem 'prawn', '0.13.2'
gem 'pdfkit', '~> 0.8.7.3'
gem 'wkhtmltopdf-binary', '~> 0.12.6.6'

gem 'aws-sdk', '~> 2' # TODO: v2 Deprecated, need to upgrade to v3
gem 'rails-observers', '~> 0.1.5' # A feature that removed from core in Rails 4.0, maybe be better migrate away from this.

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

gem 'strong_migrations', '~> 1.7'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# To use Jbuilder templates for JSON
# gem 'jbuilder', '~> 2.7'

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
	gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'annotate', "2.5.0"
  # gem 'sextant'
  # Deploy with Capistrano
  gem 'capistrano', '3.11.0', require: false
  gem 'capistrano-rails',   '1.4.0', require: false
  gem 'capistrano-bundler', '1.5.0', require: false
  gem 'capistrano-rvm', '0.1.2', require: false
  gem 'capistrano-maintenance', '1.0.0', require: false
  gem 'capistrano-passenger', '0.2.0', require: false
  gem 'capistrano-local-precompile', '1.2.0', require: false
  gem 'capistrano-sidekiq', '~> 2.3', '>= 2.3.1'
  gem 'slackistrano', '0.1.9', require: false
  gem 'brightbox', '2.3.9'
  gem 'rack-cors', '0.3.0' ,:require => 'rack/cors' # TODO: remove when upgrade Rails.
  gem 'jslint_on_rails', '1.1.1'
  # gem 'rubocop', '0.40.0', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rbnacl', '4.0.2'
  gem 'rbnacl-libsodium', '1.0.16'
  gem 'bcrypt_pbkdf', '1.1.0'
  gem 'ed25519', '1.2.4'
  # @TODO: bring back when ruby updated to > 2.6 # gem 'net-ssh', '7.0.0.beta1' # openssl 3.0 compatibility @see https://stackoverflow.com/q/72068406/1090438
end

group :test, :development do
  gem "rspec-rails", '5.1.2' # TODO: should upgrade once to rails 6.1
  gem 'rspec-collection_matchers', '~> 1.2', '>= 1.2.1'
  gem 'json_spec', '~> 1.1', '>= 1.1.5'
  gem 'database_cleaner', '~> 2.0', '>= 2.0.2'
  gem "launchy", '2.4.3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'

  gem 'rails-controller-testing'
  gem "codeclimate-test-reporter", '0.1.1', require: nil # TODO, should be removed
  gem 'factory_bot_rails', '5.2.0'
  gem 'simplecov', '~> 0.22.0', :require => false
  gem 'coveralls_reborn', '~> 0.28.0', require: false
end

gem 'geoip', '1.3.5' # TODO: no change logs, no idea if safe to update. Latest version is 1.6.4 @ 2018

gem 'request_store', '~> 1.5', '>= 1.5.1'
gem 'paper_trail', '12.3.0' # TODO: latest is 15.1.0. Can't upgrade until we fix https://github.com/paper-trail-gem/paper_trail/blob/master/doc/pt_13_yaml_safe_load.md

gem 'dotenv-rails', '2.0.1'

gem 'sitemap_generator', '~> 6.3'

gem 'appsignal', '~> 3.5', '>= 3.5.5'
gem 'test-unit', '3.1.5' # annoyingly, rails console won't start without it in staging / production

### GEM for frontend ###
# Remove the `jquery-rails` gem to eliminate any dependency issues that may block the upgrade process.
# Copy `jquery.js`, `jquery_ujs.js` and `jquery-ui.js` to the `vendor/assets/javascripts` directory.
# gem 'jquery-rails', '2.1.4' # do not upgrade until https://github.com/jquery/jquery/pull/1142 isd pulled into jquery-rails

# Remove the `jquery-ui-rails` gem to eliminate any dependency issues that may block the upgrade process.
# Download `jquery-ui-1.10.4.custom.js` from offical website and copy it to the `vendor/assets/javascripts/cites_trade` directory.
# `vendor/assets/stylesheets/cites_trade/jquery-ui-1.8.24.custom.scss` CSS is in use. No need to copy any CSS files from the gem to this project.
# gem 'jquery-ui-rails', '4.2.1'

# Remove the following gems to eliminate any dependency issues that may block the upgrade process.
# File being copied to app/assets or vendor directory.
# gem 'select2-rails', '3.5.10' # initSelection deprecated on upgrade to version 4
# gem 'jquery-mousewheel-rails', '~> 0.0.9'
# gem "font-awesome-rails", '4.5.0.1'

gem 'susy', '~> 2.2', '>= 2.2.14' # TODO: Deprecated. (https://github.com/oddbird/susy#power-tools-for-the-web-deprecated)
gem 'gon', '~> 6.4'
gem 'chartkick', '~> 5.0', '>= 5.0.5'
gem 'nested_form', '~> 0.3.2' # TODO: Deprecated. (https://github.com/ryanb/nested_form#unmaintained)
gem 'bootstrap-sass', '2.3.2.2' # TODO: latest 3.4.1 @ 2019. Can't upgrade unless we sure bootstrap v3 backward compatible with boostrap v2

# Ember
gem 'ember-rails', '~> 0.21.0' # Latest @ 2017

# NOTE: These old versions are necessary to avoid bundler fetcing newer versions
# of ember-source and ember-data-source, but actually we use even older versions
# added to version control generated by:
#
#     $ rails generate ember:install --tag=v1.6.1 --ember
#     $ rails generate ember:install --tag=v0.14 --ember-data

gem 'ember-source', '1.8.0' # NOTE: not what we actually use
gem 'ember-data-source', '1.13.0' # NOTE: not what we actually use

gem 'handlebars-source', '1.0.12' # TODO: just a wrapwrapper. Any update will change the handlebars.js version.
