class AddTrigramIndexToTradePermitNumbers < ActiveRecord::Migration[4.2]
  def up
    # Index to optimise LIKE queries
    if Rails.env.staging? or Rails.env.production?
      puts "Please add extension by hand: CREATE EXTENSION pg_trgm"
    else
      execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"
    end
    execute 'CREATE INDEX trade_permits_number_trigm_idx ON trade_permits USING gin (upper(number) gin_trgm_ops)'
  end

  def down
    execute 'DROP INDEX trade_permits_number_trigm_idx'
    if Rails.env.staging? or Rails.env.production?
      puts "Please drop extension by hand: DROP EXTENSION pg_trgm"
    else
      execute "DROP EXTENSION pg_trgm"
    end
  end
end
