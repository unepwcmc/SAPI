class UseSingleLanguage < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL.squish
    DROP TYPE api_trade_code CASCADE;
    CREATE TYPE api_trade_code AS (
      id INT,
      code TEXT,
      name TEXT
    );
    DROP TYPE api_geo_entity CASCADE;
    CREATE TYPE api_geo_entity AS (
      id INT,
      iso_code2 TEXT,
      name TEXT,
      type TEXT
    );
    SQL
  end
end
