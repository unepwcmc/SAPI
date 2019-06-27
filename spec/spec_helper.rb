require 'codeclimate-test-reporter' if ENV['CI']
require 'simplecov'
require 'coveralls'

Coveralls::Output.no_color = true

formatters = [Coveralls::SimpleCov::Formatter, SimpleCov::Formatter::HTMLFormatter]
formatters.push CodeClimate::TestReporter::Formatter if ENV['CI']

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
SimpleCov.start 'rails'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'sidekiq/testing'
require 'capybara/rspec'
require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/shared/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/models/nomenclature_change/shared/*.rb")].each { |f| require f }
RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true
  config.infer_spec_type_from_file_location!

  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, :type => :controller

  config.include FactoryGirl::Syntax::Methods
  config.include JsonSpec::Helpers
  config.include SapiSpec::Helpers

  config.before(:all) do
    DatabaseCleaner.clean_with(:deletion, { :cache_tables => false })
    @user = create(:user)
    @user.make_current
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :drops_tables => true) do
    DatabaseCleaner.strategy = :deletion, { :cache_tables => false }
    ActiveRecord::Base.connection.execute('SELECT * FROM drop_trade_sandboxes()')
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    # this is duplicated here because of the :drops_tables specs
    @user = create(:user)
    @user.make_current
  end

  config.before(:each) do |example|
    # Clears out the jobs for tests using the fake testing
    Sidekiq::Worker.clear_all
    # Get the current example from the example_method object

    if example.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!
    elsif example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!
    elsif example.metadata[:type] == :feature
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end
  end
end

def build_attributes(*args)
  FactoryGirl.build(*args).attributes.delete_if do |k, v|
    ["id", "created_at", "updated_at", "touched_at"].member?(k)
  end
end

def sign_up(user, opts = {})
  options = {
    terms_and_conditions: true
  }.merge(opts)
  visit api_path
  within('#registration-form') do
    fill_in 'user_name', :with => user.name
    fill_in 'user_email', :with => user.email
    fill_in 'Password', :with => user.password
    fill_in 'Password confirmation', :with => user.password
    find(:css, "#user_terms_and_conditions").set(options[:terms_and_conditions])
  end
  click_button 'Sign up'
end
