class CreateSomeMoreLegislationApiTypes < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL.squish
    CREATE TYPE api_annotation AS (
      symbol TEXT,
      note TEXT
    );
    SQL
  end
end
