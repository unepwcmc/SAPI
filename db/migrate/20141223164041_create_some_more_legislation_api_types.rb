class CreateSomeMoreLegislationApiTypes < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE TYPE api_annotation AS (
      symbol TEXT,
      note TEXT
    );
    SQL
  end
end
