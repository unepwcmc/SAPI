class CreateEuLegislationApiTypes < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL.squish
    CREATE TYPE api_trade_code AS (
      id INT,
      code TEXT,
      name_en TEXT,
      name_es TEXT,
      name_fr TEXT
    );
    CREATE TYPE api_eu_decision_type AS (
      id INT,
      name TEXT,
      description TEXT,
      type TEXT
    );
    SQL
  end
end
