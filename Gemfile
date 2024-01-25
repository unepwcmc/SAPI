source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.6.10'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.8.1'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'actionpack-action_caching', '~> 1.2', '>= 1.2.2' # A feature that removed from core in Rails 4.0, maybe be better migrate away from this.
gem 'actionpack-page_caching', '~> 1.2', '>= 1.2.4' # A feature that removed from core in Rails 4.0, maybe be better migrate away from this.
gem 'active_model_serializers', '0.8.4' # Deprecated
gem 'dalli', '2.7.10' # TODO: latest is 3.2.6. I believe should be fine to upgrade but we have no way to test.
gem 'pg', '~> 1.5', '>= 1.5.4'
gem 'pg_array_parser', '~> 0.0.9'
gem 'nested-hstore', '~> 0.1.2'
gem 'pg_search', '2.3.0' # TODO: can upgrade to newer version after Rails 5.2
gem 'oj', '3.14.2' # optimised JSON (picked by multi_json) # TODO: to upgrade to newer version, need >=Ruby 2.7
gem 'nokogiri', '1.12.5' # TODO: 1.12.5 is the last version support 2.5. New version need Ruby 2.6+
gem 'inherited_resources', '1.9.0' # Deprecated (https://github.com/activeadmin/inherited_resources#notice) # TODO: need upgrade when upgrade to Rails 6
gem 'mobility', '~> 1.2', '>= 1.2.9'
gem 'devise', '4.4.3' # TODO: version 4.4.3 work under <=Rails 5.3 and <=Ruby 2.6
gem 'cancancan', '2.3.0' # TODO, can upgrade to 3.0 after Rails 6
gem 'ahoy_matey', '3.3.0' # TODO: latest 5.0.2. Can't upgrade to 4.0 until upgrade to Rails 5.2
gem 'uuidtools', '~> 2.2' # For Ahoy. (https://github.com/ankane/ahoy/blob/v2.2.1/docs/Ahoy-2-Upgrade.md#activerecordstore)

# TODO: starting from v1.4, it break our test due to redirection changes:
#   rspec ./spec/controllers/admin/nomenclature_changes/lump_controller_spec.rb:147
#   rspec ./spec/controllers/admin/nomenclature_changes/split_controller_spec.rb:191
gem 'wicked', '1.3.4'

gem 'groupdate', '5.2.4' # TODO: can upgrade after rails 5.2 and newer ruby 2.6

gem 'rubyzip', '~> 2.3', '>= 2.3.2'
gem 'responders', '~> 2.0' # https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders

# TODO: need Sidekiq 6 and Rails 6, before we can migrate worker to job, due to sidekiq_options (https://github.com/sidekiq/sidekiq/issues/4281)
gem 'sidekiq', '5.2.10' # TODO, Ruby 2.7 need version 6.0.5 sidekiq
gem 'sidekiq-status', '2.1.3' # TODO: upgrade to v3 when Sidekiq upgrade to 6
gem 'sidekiq-unique-jobs', '7.1.31' # TODO: can upgrade to latest when sidekiq upgrade to 7
gem 'redis-rails', '5.0.2' # TODO: latest, may remove this Gem when upgrade to Rails 5.2. (https://github.com/redis-store/redis-rails/tree/master#a-quick-note-about-rails-52)

gem 'whenever', '0.11.0', :require => false # TODO: latest version 1.0 @ 2019. Should migrate to sidekiq-cron.
gem 'httparty', '~> 0.21.0'

gem 'kaminari', '~> 1.2', '>= 1.2.2' # TODO: Suggest migrate to pagy gem.

gem 'acts-as-taggable-on', '8.1.0' # TODO: latest v10 @ 2023. Can upgrade after upgrade to Rails 6.
gem 'carrierwave', '2.2.5' # TODO: latest is 3.0.5 @ 2023. can upgrade to v3 after Rails 6

# PDF
gem 'prawn', '0.13.2'
gem 'pdfkit', '~> 0.8.7.3'
gem 'wkhtmltopdf-binary', '~> 0.12.6.6'

gem 'aws-sdk', '~> 2' # TODO: v2 Deprecated, need to upgrade to v3
gem 'rails-observers', '~> 0.1.5' # A feature that removed from core in Rails 4.0, maybe be better migrate away from this.

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

gem 'strong_migrations', '0.7.9' # TODO: should upgrade when we upgrade to rails 5.2

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# To use Jbuilder templates for JSON
# gem 'jbuilder', '~> 2.5'

gem 'rest-client', '1.8.0', require: false # TODO, should upgrade for better compatibility with newer Ruby but breaking change. Seems not many place using it, worth a try.

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
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
  gem 'capistrano-sidekiq', '1.0.2'
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
  gem "rspec-rails", '4.1.1' # TODO: should upgrade once to rails 5.2
  gem 'rspec-collection_matchers', '~> 1.2', '>= 1.2.1'
  gem "json_spec", '1.1.5'
  gem 'database_cleaner', '~> 2.0', '>= 2.0.2'
  gem "launchy", '2.4.3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
end

group :test do
  gem 'rails-controller-testing'
  gem "codeclimate-test-reporter", '0.1.1', require: nil # TODO, should be removed
  gem 'factory_bot_rails', '4.11.1'
  gem 'simplecov', '0.22.0', :require => false # TODO: latest
  gem 'coveralls', '0.7.1', :require => false
end

gem 'geoip', '1.3.5' # TODO: no change logs, no idea if safe to update. Latest version is 1.6.4 @ 2018

gem 'request_store', '~> 1.5', '>= 1.5.1'
gem 'paper_trail', '10.3.1' # TODO: latest is 15.1.0. Can upgrade to newer version when we at Rails 5.2

gem 'dotenv-rails', '2.0.1'

gem 'sitemap_generator', '~> 6.3'

gem 'appsignal', '1.3.3' # TODO: should upgrade to latest after all upgrade.
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
gem "chartkick", '2.3.5' # TODO: latest 5.0.5 @ 2023. Should upgrade to v4 once we upgrade to Rails 5.2+ and Ruby 2.6+
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
