source 'https://rubygems.org'

ruby '2.5.9'

gem 'rails', '4.2.11.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'actionpack-action_caching', '1.2.0'
gem 'actionpack-page_caching', '1.1.1'
gem 'active_model_serializers', '0.8.4'
gem 'activeresource', '4.1.0' # TODO: can be removed? Seems no place using this.
gem 'dalli', '2.7.10' # TODO: latest is 3.2.6. I believe should be fine to upgrade but we have no way to test.
gem 'pg', '0.21.0' # TODO: latest 1.5.4, need Rails 5 to upgrade to 1.0.0
gem 'pg_array_parser', '0.0.9' # TODO: latest 0.0.9
gem 'nested-hstore', '0.1.2' # TODO: latest 0.1.2 @ 2015
gem 'pg_search', '1.0.6' # TODO: update to newer version when upgrade to Rails 5
gem 'oj', '3.14.2' # optimised JSON (picked by multi_json) # TODO: to upgrade to newer version, need >=Ruby 2.7
gem 'nokogiri', '1.12.5' # TODO: 1.12.5 is the last version support 2.5. New version need Ruby 2.6+
gem 'inherited_resources', '1.7.2' # TODO: need upgrade when upgrade to Rails 5
gem 'traco', '~> 5.3', '>= 5.3.3' # TODO: latest version @ 2021. Suggest migrate to Mobility gem.
# gem 'strong_parameters'
gem 'protected_attributes', '1.1.4' # TODO: Only support Rails version < 5 (https://github.com/rails/protected_attributes)
gem 'devise', '4.4.3' # TODO: version 4.4.3 work under <=Rails 5.3 and <=Ruby 2.6
gem 'cancancan', '1.17.0' # TODO, need upgrade to 2.0 for Rails 5
gem 'ahoy_matey', '1.6.1' # TODO: latest 5.0.2. Can't upgrade to 2.0 until upgrade to Rails 5
gem 'browser', '2.5.3' # Latest 5.3.1 @ 2021, doesn't work with this project, maybe try again after upgrade ruby > 2.5 and rails >= 5

gem 'wicked', '1.3.3'
gem 'groupdate', '2.4.0'

gem 'rubyzip', '~> 2.3', '>= 2.3.2' # TODO: latest
gem 'responders', '~> 2.0' # https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders

gem 'sidekiq', '4.2.10' # TODO, Ruby 2.7 need version 6.0.5 sidekiq
gem 'sidekiq-status', '1.1.4' # TODO: latest is 3.0.3 @ 2023
gem 'sidekiq-unique-jobs', '4.0.18'
gem 'redis-rails', '4.0.0'

gem 'whenever', '0.11.0', :require => false # TODO: latest version 1.0 @ 2019. Should migrate to sidekiq-cron.
gem 'httparty', '~> 0.21.0' # TODO: latest.

gem 'sprockets', '2.12.5' # upgrading to 3 breaks handlebars/tilt
gem 'ember-rails', '0.14.1'
gem 'ember-source', '1.6.1'
gem 'ember-data-source', '0.14'
gem 'handlebars-source', '1.0.12'
gem 'jquery-rails', '2.1.4' # do not upgrade until https://github.com/jquery/jquery/pull/1142 isd pulled into jquery-rails
gem 'jquery-mousewheel-rails', '0.0.9'
gem 'jquery-cookie-rails', '1.3.1.1'
gem 'bootstrap-sass', '2.3.2.2'
gem 'kaminari', '1.2.2' # TODO: latest @ 2021. Suggest migrate to pagy gem.
gem 'select2-rails', '3.5.10' #initSelection deprecated on upgrade to version 4

gem 'acts-as-taggable-on', '4.0.0'
gem 'carrierwave', '1.3.1' # TODO: latest is 3.0.5 @ 2023. v2 support Rails 5
gem 'prawn', '0.13.2'
gem 'pdfkit', '0.8.4.2'
gem 'wkhtmltopdf-binary', '0.9.9.3'

gem 'underscore-rails', '1.4.3'
gem "font-awesome-rails", '4.5.0.1'

gem 'aws-sdk', '~> 2' # TODO: v2 Deprecated, need to upgrade to v3
gem 'rails-observers', '0.1.5' # TODO: a feature that removed since Rails 4...

# Gems used for assets
gem 'sass-rails',   '5.0.7'
gem 'coffee-rails', '4.1.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '2.7.2' # TODO: Only works with ES5. Latest version 4.2.0 @ 2019



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
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem "guard-livereload", '1.1.3'
  gem "rack-livereload", '0.3.11'
  gem "guard-bundler", '1.0.0'
  gem 'annotate', "2.5.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
	gem 'spring'
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
  gem "rspec-rails", '3.9.1'
  gem 'rspec-collection_matchers', '1.1.3'
  gem "json_spec", '1.1.5'
  gem "database_cleaner", "1.2.0" # TODO, should remove after upgrade Rails.
  gem "launchy", '2.4.3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :test do
  gem "codeclimate-test-reporter", '0.1.1', require: nil # TODO, should be removed
  gem "factory_girl_rails", '4.2.1'
  gem 'simplecov', '0.22.0', :require => false # TODO: latest
  gem 'coveralls', '0.7.1', :require => false
  gem 'capybara', '2.2.1'
end

gem 'geoip', '1.3.5' # TODO: no change logs, no idea if safe to update. Latest version is 1.6.4 @ 2018

# track who created or edited a given object
gem 'clerk', '0.2.3' # TODO: Need update to 1.0.0 when upgrade to Rails 5. I would say should update our code and just use paper_trail. This gem last update at 2018.
gem 'paper_trail', '4.2.0' # TODO: latest is 15.1.0. Need upgrade to v5 for Rails 5.

gem 'dotenv-rails', '2.0.1'

gem 'sitemap_generator', '~> 6.3' # TODO: latest

gem 'appsignal', '1.3.3'
gem 'test-unit', '3.1.5' # annoyingly, rails console won't start without it in staging / production

# GEM for frontend.
gem 'jquery-ui-rails', '4.2.1' # TODO: some breaking change form v5. Latest version 6.0.1 @ 2016
# gem 'slim', '1.3.6' # I believe not in-use as we do not have .slim file.
gem 'susy', '2.2.14' # TODO: Deprecated. 2.2.14 is the latest version @ 2018
gem 'gon', '~> 6.4' # TODO: latest
gem "chartkick", '2.3.5' # TODO: latest 5.0.5 @ 2023. Should upgrade to v4 once we upgrade to Rails 5.2+ and Ruby 2.6+
gem 'nested_form', '0.3.2' # TODO: latest @ 2013. Project is public archived on github. No longer maintained.
