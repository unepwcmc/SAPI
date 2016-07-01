require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::NonCitesTaxaImporter
  include Elibrary::Importable

  def initialize(file_name)
    @file_name = file_name
  end

  def table_name
    :elibrary_non_cites_taxa_import
  end

  def columns_with_type
    [
      ['normalised_name', 'TEXT'],
      ['notes', 'TEXT'],
      ['genus_name', 'TEXT'],
      ['genus_id', 'INT'],
      ['species_name', 'TEXT'],
      ['species_id', 'INT'],
      ['rank', 'TEXT'],
      ['parent_id', 'TEXT'],
      ['Family', 'TEXT'],
      ['Comments', 'TEXT']
    ]
  end

  def run_preparatory_queries
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET parent_id = NULL WHERE parent_id = '#N/A'")
  end

  def run_queries
    # insert taxon names
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      ), taxon_names_to_insert AS (
        SELECT normalised_name FROM rows_to_insert
        EXCEPT
        SELECT scientific_name FROM taxon_names
      )
      INSERT INTO taxon_names (scientific_name, created_at, updated_at)
      SELECT
        normalised_name,
        NOW(),
        NOW()
      FROM taxon_names_to_insert
    SQL
    ActiveRecord::Base.connection.execute(sql)

    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      )
      INSERT INTO "taxon_concepts" (taxon_name_id, full_name, rank_id, parent_id, taxonomy_id, name_status, created_at, updated_at)
        SELECT
        taxon_names.id,
        normalised_name,
        rank_id,
        parent_id,
        taxonomy_id,
        name_status,
        NOW(),
        NOW()
      FROM rows_to_insert
      JOIN taxon_names
      ON normalised_name = taxon_names.scientific_name
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def all_rows_sql
    cites_eu = Taxonomy.find_by_name('CITES_EU')
    sql = <<-SQL
      SELECT
        normalised_name,
        ranks.id AS rank_id,
        CAST(parent_id AS INT) AS parent_id,
        #{cites_eu.id} AS taxonomy_id,
        'N' AS name_status
      FROM #{table_name} t
      JOIN ranks ON ranks.name = UPPER(BTRIM(t.rank))
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_sql}
      ) all_rows_in_table_name
      WHERE normalised_name IS NOT NULL AND rank_id IS NOT NULL
      EXCEPT
      SELECT full_name, rank_id, parent_id, taxonomy_id, name_status
      FROM taxon_concepts WHERE name_status = 'N'
    SQL
  end

  def print_breakdown
    puts "#{Time.now} There are #{TaxonConcept.where(name_status: 'N').count} N taxa in total"
  end

end
