require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc "Import species records from csv files (usage: rake import:species[path/to/file,path/to/another])"
  task :species, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'species_import'
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      #import_data_for Rank::KINGDOM
      import_data_for kingdom, Rank::PHYLUM
      import_data_for kingdom, Rank::CLASS
      import_data_for kingdom, Rank::ORDER
      import_data_for kingdom, Rank::FAMILY
      import_data_for kingdom, Rank::SUBFAMILY
      import_data_for kingdom, Rank::GENUS
      import_data_for kingdom, Rank::SPECIES
      import_data_for kingdom, Rank::SUBSPECIES
      if kingdom == 'Plantae'
        import_data_for kingdom, Rank::VARIETY
      end
    end
  end
end

# Copies data from the temporary table to the correct tables in the database
#
# @param [String] which the rank to be copied.
def import_data_for kingdom, rank, synonyms=nil
  puts "Importing #{rank}"
  rank_id = Rank.select(:id).where(:name => rank).first.id
  existing = TaxonConcept.where(:rank_id => rank_id).count
  puts "There were #{existing} #{rank} before we started"

  sql = <<-SQL
    INSERT INTO taxon_names(scientific_name, created_at, updated_at)
      SELECT DISTINCT INITCAP(BTRIM(#{TMP_TABLE}.Name)), current_date, current_date
      FROM #{TMP_TABLE}
      WHERE NOT EXISTS (
        SELECT scientific_name
        FROM taxon_names
        WHERE UPPER(BTRIM(scientific_name)) = UPPER(BTRIM(#{TMP_TABLE}.Name))
      )
      AND UPPER(BTRIM(#{TMP_TABLE}.Name)) <> 'NULL'
      AND UPPER(BTRIM(#{TMP_TABLE}.Rank)) = UPPER('#{rank}')
      AND (
        BTRIM(#{TMP_TABLE}.Taxonomy) iLIKE '%CITES%'
        OR BTRIM(#{TMP_TABLE}.Taxonomy) iLIKE '%CMS%'
      )
  SQL
  ActiveRecord::Base.connection.execute(sql)

  ActiveRecord::Base.connection.execute('CREATE INDEX species_import_name ON species_import (name)')

  [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy|
    taxonomy = Taxonomy.find_by_name(taxonomy)
    sql = <<-SQL
      WITH to_be_inserted AS (
        SELECT DISTINCT
          taxon_names.id AS taxon_name_id,
          #{rank_id} AS rank_id,
          #{taxonomy.id} AS taxonomy_id,
          parent_taxon_concepts.id AS parent_id,
          CASE
            WHEN UPPER(BTRIM(tmp.author)) = 'NULL' THEN NULL
            ELSE BTRIM(tmp.author)
          END AS author_year,
          tmp.legacy_id,
          '#{kingdom}' AS legacy_type,
          tmp.notes,
          UPPER(BTRIM(tmp.status)) AS name_status,
          hstore('accepted_legacy_id', #{synonyms ? 'accepted_legacy_id::VARCHAR' : 'NULL'}) ||
          hstore('accepted_rank', #{synonyms ? 'UPPER(BTRIM(accepted_rank))' : 'NULL'}) AS data,
          current_date, current_date
        FROM #{TMP_TABLE} tmp
        INNER JOIN taxon_names
          ON UPPER(taxon_names.scientific_name) = UPPER(BTRIM(tmp.name))
        LEFT JOIN ranks parent_ranks
          ON UPPER(BTRIM(parent_ranks.name)) = UPPER(BTRIM(tmp.parent_rank))
        LEFT JOIN taxon_concepts parent_taxon_concepts
          ON (
            parent_taxon_concepts.legacy_id = tmp.parent_legacy_id
            AND parent_taxon_concepts.rank_id = parent_ranks.id
            AND parent_taxon_concepts.legacy_type = '#{kingdom}'
            AND parent_taxon_concepts.taxonomy_id = #{taxonomy.id}
          )
        WHERE
        UPPER(BTRIM(tmp.rank)) = UPPER('#{rank}')
        AND UPPER(BTRIM(tmp.taxonomy)) LIKE UPPER('%#{taxonomy.name}%')
        AND (
          parent_taxon_concepts.id IS NOT NULL AND parent_ranks.id IS NOT NULL
          OR tmp.parent_legacy_id IS NULL
        )
      )
      INSERT INTO taxon_concepts(
        taxon_name_id, rank_id, taxonomy_id, parent_id,
        author_year, legacy_id, legacy_type, notes, name_status, data,
        created_at, updated_at
      )
      SELECT * FROM to_be_inserted
      WHERE NOT EXISTS (
        SELECT to_be_inserted.taxon_name_id
        FROM to_be_inserted
        INNER JOIN taxon_concepts
          ON
            taxon_concepts.taxon_name_id = to_be_inserted.taxon_name_id
            AND taxon_concepts.rank_id = to_be_inserted.rank_id
            AND taxon_concepts.taxonomy_id = to_be_inserted.taxonomy_id
            AND taxon_concepts.parent_id = to_be_inserted.parent_id
            AND UPPER(taxon_concepts.name_status) = UPPER(to_be_inserted.name_status)
            AND taxon_concepts.legacy_id = to_be_inserted.legacy_id
            AND UPPER(taxon_concepts.legacy_type) = UPPER(to_be_inserted.legacy_type)
            AND (
              (taxon_concepts.data->'accepted_legacy_id')::INT IS NULL
              OR (
                (taxon_concepts.data->'accepted_legacy_id')::INT = (to_be_inserted.data->'accepted_legacy_id')::INT
                AND UPPER(BTRIM(taxon_concepts.data->'accepted_rank')) = to_be_inserted.data->'accepted_rank'
              )
            )
      )
      RETURNING id;
    SQL

    # puts "#{taxonomy.name} #{rank} #{kingdom}"
    # puts sql

    ActiveRecord::Base.connection.execute(sql)
    # sql = <<-SQL
      # WITH fake_parents_of_synonyms AS (
        # UPDATE taxon_concepts
        # SET parent_id = NULL
        # WHERE name_status = 'S' AND parent_id IS NOT NULL
        # RETURNING parent_id AS id
      # )
      # DELETE FROM taxon_concepts WHERE id IN (SELECT id FROM fake_parents_of_synonyms)
    # SQL
    # ActiveRecord::Base.connection.execute(sql)
  end
  puts "#{TaxonConcept.where(:rank_id => rank_id).count - existing} #{rank} added"
  ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS species_import_name')
end
