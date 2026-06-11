# This file is copied to spec/ when you run 'rails generate rspec:install'

require 'simplecov'
require 'coveralls'

Coveralls::Output.no_color = true

formatters = [
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.formatters = formatters
SimpleCov.start 'rails' do
  add_group 'Services', 'app/services'
  add_group 'Serializers', 'app/serializers'
end

# CHANGED
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'sidekiq/testing'
require 'capybara/rspec'
require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/shared/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/models/nomenclature_change/shared/*.rb')].each { |f| require f }
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

  config.include ActiveSupport::Testing::TimeHelpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.extend ControllerMacros, type: :controller

  config.include FactoryBot::Syntax::Methods
  config.include JsonSpec::Helpers
  config.include SapiSpec::Helpers

  config.before(:suite) do
    # `DatabaseCleaner.clean_with(:deletion, cache_tables: false)` used to be
    # the suite-wide reset, but on this schema it needs far too many locks and
    # eventually trips Postgres shared-memory / out-of-lock errors. We still
    # need a clean starting point for each RSpec process because FactoryBot
    # sequences restart from the beginning and will collide with stale rows in
    # a reused test database. Truncating once up front keeps that deterministic
    # empty baseline without repeating the old expensive table-by-table
    # deletion sweep.
    primary_tables = ApplicationRecord.connection.tables - %w[
      ar_internal_metadata
      schema_migrations
      spatial_ref_sys
    ]
    if primary_tables.any?
      quoted_primary_tables = primary_tables.map do |table_name|
        ApplicationRecord.connection.quote_table_name(table_name)
      end.join(', ')
      ApplicationRecord.connection.execute(
        "TRUNCATE TABLE #{quoted_primary_tables} RESTART IDENTITY CASCADE"
      )
    end

    # The captive-breeding database is managed outside Rails' normal database
    # tasks, but specs that create users still sync into its `users` table.
    # Reset that table too when the auxiliary schema has been bootstrapped, so
    # cross-database uniqueness checks start from a clean state as well.
    if CaptiveBreedingRecord.connection.data_source_exists?('users')
      CaptiveBreedingRecord.connection.execute(
        'TRUNCATE TABLE public.users RESTART IDENTITY CASCADE'
      )
    end
  end

  config.before(:all) do
    # https://github.com/thoughtbot/factory_bot/issues/1255
    # https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#build-strategies-1
    FactoryBot.use_parent_strategy = false

    DatabaseCleaner.clean_with(:deletion, { cache_tables: false })
    @user = create(:user)
    RequestStore.store[:track_who_does_it_current_user] = @user
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, drops_tables: true) do
    DatabaseCleaner.strategy = :deletion, { cache_tables: false }
    ApplicationRecord.connection.execute('SELECT * FROM drop_trade_sandboxes()')
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    # this is duplicated here because of the :drops_tables specs
    @user = create(:user)
    RequestStore.store[:track_who_does_it_current_user] = @user
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

  config.before(:each) do |example|
    if example.metadata[:cache]
      memory_store = ActiveSupport::Cache.lookup_store(:memory_store)

      allow(
        Rails.application.config.action_controller
      ).to receive(:perform_caching).and_return(true)

      allow(Rails).to receive(:cache).and_return(memory_store)

      Rails.cache.clear
    end
  end
end

def build_attributes(*args)
  FactoryBot.build(*args).attributes.delete_if do |k, v|
    [ 'id', 'created_at', 'updated_at', 'touched_at' ].member?(k)
  end
end
