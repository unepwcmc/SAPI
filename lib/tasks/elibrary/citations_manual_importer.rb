require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::CitationsManualImporter
  include Elibrary::Importable

  def initialize(file_name)
    @file_name = file_name
    @file_name =~ /citations_(.+)\.csv$/
    @document_group = $1
  end

  def table_name
    :"elibrary_citations_#{@document_group}_import"
  end

  def columns_with_type
    [
      ['splus_taxon_concept_id', 'TEXT'],
      ['Manual_ID', 'TEXT']
    ]
  end

  def run_preparatory_queries
    ActiveRecord::Base.connection.execute(
      <<-SQL
      BEGIN;
        CREATE TABLE temp_table (LIKE #{table_name});

        INSERT INTO temp_table
          SELECT unnest(string_to_array(splus_taxon_concept_id, ',')) AS splus_taxon_concept_id, manual_id
          FROM #{table_name};

        DROP TABLE #{table_name};
        
        ALTER TABLE temp_table RENAME TO #{table_name};
      COMMIT;
      SQL
    )
  end

  def run_queries

    ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS elibrary_citations_resolved_tmp')
    ActiveRecord::Base.connection.execute('CREATE TABLE elibrary_citations_resolved_tmp (document_id INT, taxon_concept_id INT)')
    ActiveRecord::Base.connection.execute(
      <<-SQL
      INSERT INTO elibrary_citations_resolved_tmp (document_id, taxon_concept_id)
        SELECT
          t.doc_id,
          t.taxon_concept_id
        FROM (
          #{rows_to_insert_sql}
        ) t
      SQL
    )

    ActiveRecord::Base.connection.execute('CREATE INDEX ON elibrary_citations_resolved_tmp (document_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX ON elibrary_citations_resolved_tmp (taxon_concept_id)')

    sql = <<-SQL
      WITH inserted_citations AS (
        INSERT INTO document_citations (
          document_id,
          created_at,
          updated_at
        )
        SELECT DISTINCT
          document_id,
          NOW(),
          NOW()
        FROM elibrary_citations_resolved_tmp rows_to_insert_resolved
        RETURNING *
      )
      INSERT INTO document_citation_taxon_concepts (
        document_citation_id,
        taxon_concept_id,
        created_at,
        updated_at
      )
      SELECT DISTINCT
        inserted_citations.id,
        taxon_concept_id,
        NOW(),
        NOW()
      FROM elibrary_citations_resolved_tmp rows_to_insert_resolved
      JOIN inserted_citations ON inserted_citations.document_id = rows_to_insert_resolved.document_id
      WHERE taxon_concept_id IS NOT NULL
    SQL
    ActiveRecord::Base.connection.execute(sql)
    ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS elibrary_citations_resolved_tmp')
  end

  def rows_to_insert_sql
    sql = <<-SQL
      WITH rows_to_insert AS (
        SELECT DISTINCT
          d.id AS doc_id,
          CAST(r.splus_taxon_concept_id AS INT) AS taxon_concept_id
        FROM #{table_name} r
        JOIN documents d
        ON d.manual_id = r.manual_id
      )
      SELECT
        doc_id,
        taxon_concept_id
      FROM rows_to_insert
      JOIN taxon_concepts ON taxon_concept_id = taxon_concepts.id
      WHERE taxon_concept_id IS NOT NULL

      EXCEPT

      SELECT DISTINCT
        d.id,
        c_tc.taxon_concept_id
      FROM rows_to_insert r
      JOIN document_citations c ON c.document_id = r.doc_id
      JOIN documents d ON c.document_id = d.id
      JOIN document_citation_taxon_concepts c_tc ON c_tc.taxon_concept_id = r.taxon_concept_id
    SQL
  end

  def print_breakdown
    puts "#{Time.now} There are #{DocumentCitation.count} citations in total"
    DocumentCitation.includes(:document).group('documents.type').order('documents.type').count.each do |type, count|
      puts "\t #{type} #{count}"
    end
  end

end
