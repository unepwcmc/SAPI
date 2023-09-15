class AddTrigramIndexToTradePermitNumbers < ActiveRecord::Migration
  def up
    # Index to optimise LIKE queries
    execute 'CREATE INDEX trade_permits_number_trigm_idx ON trade_permits USING gin (upper(number) gin_trgm_ops)'
  end

  def down
    execute 'DROP INDEX trade_permits_number_trigm_idx'
  end
end
