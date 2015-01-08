class CreateLegislationApiTypes < ActiveRecord::Migration
  def change
    execute <<-SQL
    DROP TYPE IF EXISTS api_taxon_concept CASCADE;
    CREATE TYPE api_taxon_concept AS (
      id INT,
      full_name TEXT,
      author_year TEXT,
      rank TEXT
    );
    DROP TYPE IF EXISTS api_event CASCADE;
    CREATE TYPE api_event AS (
      name TEXT,
      date DATE,
      url TEXT
    );
    DROP TYPE IF EXISTS api_geo_entity CASCADE;
    CREATE TYPE api_geo_entity AS (
      id INT,
      iso_code2 TEXT,
      name_en TEXT,
      name_es TEXT,
      name_fr TEXT,
      type TEXT
    );
    SQL
  end
end
