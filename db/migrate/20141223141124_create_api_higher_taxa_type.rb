class CreateApiHigherTaxaType < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL.squish
    DROP TYPE IF EXISTS api_higher_taxa CASCADE;
    CREATE TYPE api_higher_taxa AS (
      kingdom TEXT,
      phylum TEXT,
      class TEXT,
      "order" TEXT,
      family TEXT
    );
    SQL
  end
end
