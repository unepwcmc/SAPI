class CreateApiHigherTaxaType < ActiveRecord::Migration
  def change
    execute <<-SQL
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
