require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::CitationsImporter
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
      ['EventTypeID', 'TEXT'],
      ['EventTypeName', 'TEXT'],
      ['splus_event_type', 'TEXT'],
      ['EventID', 'TEXT'],
      ['EventName', 'TEXT'],
      ['EventDate', 'TEXT'],
      ['MeetingType', 'TEXT'],
      ['EventDocumentReference', 'TEXT'],
      ['DocumentOrder', 'TEXT'],
      ['DocumentTypeID', 'TEXT'],
      ['DocumentTypeName', 'TEXT'],
      ['splus_document_type', 'TEXT'],
      ['DocumentID', 'TEXT'],
      ['DocumentTitle', 'TEXT'],
      ['supertitle', 'TEXT'],
      ['subtitle', 'TEXT'],
      ['DocumentDate', 'TEXT'],
      ['DocumentFileName', 'TEXT'],
      ['DocumentFilePath', 'TEXT'],
      ['DocumentIsPubliclyAccessible', 'TEXT'],
      ['DateCreated', 'TEXT'],
      ['DateModified', 'TEXT'],
      ['LanguageName', 'TEXT'],
      ['DocumentIsTranslationIntoEnglish', 'TEXT'],
      ['CitationID', 'INT'],
      ['CtyRecID', 'TEXT'],
      ['CtyShort', 'TEXT'],
      ['CtyISO2', 'TEXT'],
      ['SpeciesID', 'TEXT'],
      ['SpeciesName', 'TEXT'],
      ['splus_taxon_concept_id', 'TEXT'],
      ['CtyShortCombined', 'TEXT'],
      ['SpeciesNameCombined', 'TEXT']
    ]
  end

  def run_preparatory_queries
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET splus_taxon_concept_id = NULL WHERE splus_taxon_concept_id LIKE '%N/A%'")
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET CtyISO2 = NULL WHERE CtyISO2='NULL'")
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET EventID = NULL WHERE EventID='NULL'")
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET DocumentID = NULL WHERE DocumentID='NULL'")
  end

  def run_queries
    ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS elibrary_citations_resolved_tmp')
    ActiveRecord::Base.connection.execute('CREATE TABLE elibrary_citations_resolved_tmp (document_id INT, CitationId INT, CtyISO2 TEXT, splus_taxon_concept_id INT)')
    ActiveRecord::Base.connection.execute(
      <<-SQL
      INSERT INTO elibrary_citations_resolved_tmp (document_id, CitationId, CtyISO2, splus_taxon_concept_id)
        SELECT
        d.id AS document_id,
        CitationID,
        UPPER(BTRIM(CtyISO2)) AS CtyISO2,
        splus_taxon_concept_id
        FROM (
          #{rows_to_insert_sql}
        ) rows_to_insert
        JOIN documents d ON d.elib_legacy_id = rows_to_insert.DocumentID
      SQL
    )

    ActiveRecord::Base.connection.execute('CREATE INDEX ON elibrary_citations_resolved_tmp (CitationID, document_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX ON elibrary_citations_resolved_tmp (CtyISO2)')
    ActiveRecord::Base.connection.execute('CREATE INDEX ON elibrary_citations_resolved_tmp (splus_taxon_concept_id)')

    sql = <<-SQL
      WITH inserted_citations AS (
        INSERT INTO document_citations (
          document_id,
          elib_legacy_id,
          created_at,
          updated_at
        )
        SELECT
          document_id,
          CitationID,
          NOW(),
          NOW()
        FROM elibrary_citations_resolved_tmp rows_to_insert_resolved
        RETURNING *
      ), inserted_citations_geo_entity AS (
        INSERT INTO document_citation_geo_entities (
          document_citation_id,
          geo_entity_id,
          created_at,
          updated_at
        )
        SELECT DISTINCT
          inserted_citations.id,
          geo_entities.id,
          NOW(),
          NOW()
        FROM elibrary_citations_resolved_tmp rows_to_insert_resolved
        JOIN inserted_citations ON inserted_citations.elib_legacy_id = rows_to_insert_resolved.CitationID
        JOIN geo_entities ON UPPER(BTRIM(geo_entities.iso_code2)) = rows_to_insert_resolved.CtyISO2
      )
      INSERT INTO document_citation_taxon_concepts (
        document_citation_id,
        taxon_concept_id,
        created_at,
        updated_at
      )
      SELECT DISTINCT
        inserted_citations.id,
        splus_taxon_concept_id,
        NOW(),
        NOW()
      FROM elibrary_citations_resolved_tmp rows_to_insert_resolved
      JOIN inserted_citations ON inserted_citations.elib_legacy_id = rows_to_insert_resolved.CitationID
      WHERE splus_taxon_concept_id IS NOT NULL
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def all_rows_sql
    columns = [
      'CAST(DocumentID AS INT) AS DocumentID',
      'CAST(CitationID AS INT) AS CitationID',
      'CtyISO2',
      'CAST(splus_taxon_concept_id AS INT) AS splus_taxon_concept_id'
    ]
    "SELECT #{columns.join(', ')} FROM #{table_name} t"
  end

  def rows_to_insert_sql
    sql = <<-SQL
        #{geo_entity_and_taxon_concept_rows_to_insert_sql}
        UNION ALL
        #{geo_entity_rows_to_insert_sql}
        UNION ALL
        #{taxon_concept_rows_to_insert_sql}
    SQL
  end

  # both geo entity and taxon concept present
  def geo_entity_and_taxon_concept_rows_to_insert_sql
    sql = <<-SQL
      SELECT all_rows_in_table_name.* FROM (
        #{all_rows_sql}
      ) all_rows_in_table_name
      JOIN taxon_concepts ON splus_taxon_concept_id = taxon_concepts.id
      WHERE CtyISO2 IS NOT NULL
        AND splus_taxon_concept_id IS NOT NULL
      EXCEPT
      SELECT
        d.elib_legacy_id,
        c.elib_legacy_id,
        geo_entities.iso_code2,
        c_tc.taxon_concept_id
      FROM (
        #{all_rows_sql}
      ) nc
      JOIN document_citations c ON c.elib_legacy_id = nc.CitationID
      JOIN documents d ON c.document_id = d.id
      JOIN document_citation_geo_entities c_g ON c_g.document_citation_id = d.id
      JOIN geo_entities ON geo_entities.id = c_g.geo_entity_id
      JOIN document_citation_taxon_concepts c_tc ON c_tc.document_citation_id = d.id
    SQL
  end

  # only geo entity present
  def geo_entity_rows_to_insert_sql
    sql = <<-SQL
      SELECT all_rows_in_table_name.* FROM (
        #{all_rows_sql}
      ) all_rows_in_table_name
      JOIN taxon_concepts ON splus_taxon_concept_id = taxon_concepts.id
      WHERE CtyISO2 IS NOT NULL
        AND splus_taxon_concept_id IS NULL
      EXCEPT
      SELECT
        d.elib_legacy_id,
        c.elib_legacy_id,
        geo_entities.iso_code2,
        NULL
      FROM (
        #{all_rows_sql}
      ) nc
      JOIN document_citations c ON c.elib_legacy_id = nc.CitationID
      JOIN documents d ON c.document_id = d.id
      JOIN document_citation_geo_entities c_g ON c_g.document_citation_id = d.id
      JOIN geo_entities ON geo_entities.id = c_g.geo_entity_id
    SQL
  end

  # only taxon concpet taxon concept present
  def taxon_concept_rows_to_insert_sql
    sql = <<-SQL
      SELECT all_rows_in_table_name.* FROM (
        #{all_rows_sql}
      ) all_rows_in_table_name
      JOIN taxon_concepts ON splus_taxon_concept_id = taxon_concepts.id
      WHERE CtyISO2 IS NULL
        AND splus_taxon_concept_id IS NOT NULL
      EXCEPT
      SELECT
        d.elib_legacy_id,
        c.elib_legacy_id,
        NULL,
        c_tc.taxon_concept_id
      FROM (
        #{all_rows_sql}
      ) nc
      JOIN document_citations c ON c.elib_legacy_id = nc.CitationID
      JOIN documents d ON c.document_id = d.id
      JOIN document_citation_taxon_concepts c_tc ON c_tc.document_citation_id = d.id
    SQL
  end

  def print_breakdown
    puts "#{Time.now} There are #{DocumentCitation.count} citations in total"
    DocumentCitation.includes(:document).group('documents.type').order('documents.type').count.each do |type, count|
      puts "\t #{type} #{count}"
    end
  end

end
