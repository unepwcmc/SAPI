require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::CitationsImporter
  include Elibrary::Importable

  def initialize(file_name)
    @file_name = file_name
    @file_name =~ /citations_(.+)\.csv$/
    @document_group = $1
  end

  def table_name; :"elibrary_citations_#{@document_group}_import"; end

  def columns_with_type
    [
      ['EventTypeID', 'TEXT'],
      ['EventTypeName', 'TEXT'],
      ['splus_event_type', 'TEXT'],
      ['EventID', 'INT'],
      ['EventName', 'TEXT'],
      ['EventDate', 'TEXT'],
      ['MeetingType', 'TEXT'],
      ['EventDocumentReference', 'TEXT'],
      ['DocumentOrder', 'TEXT'],
      ['DocumentTypeID', 'TEXT'],
      ['DocumentTypeName', 'TEXT'],
      ['splus_document_type', 'TEXT'],
      ['DocumentID', 'INT'],
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
      ['splus_taxon_concept_id', 'INT'],
      ['CtyShortCombined', 'TEXT'],
      ['SpeciesNameCombined', 'TEXT']
    ]
  end

  def run_preparatory_queries
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET CtyISO2 = NULL WHERE CtyISO2='NULL'" )
  end

  def run_queries
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      ), rows_to_insert_resolved AS (
        SELECT
        d.id AS document_id,
        CitationID,
        geo_entities.id AS geo_entity_id,
        splus_taxon_concept_id
        FROM rows_to_insert
        JOIN documents d ON d.elib_legacy_id = rows_to_insert.DocumentID
        JOIN geo_entities ON UPPER(BTRIM(geo_entities.iso_code2)) = UPPER(BTRIM(rows_to_insert.CtyISO2))
      ), inserted_citations AS (
        INSERT INTO document_citations (
          document_id,
          elib_legacy_id,
          created_at,
          updated_at
        )
        SELECT
          rows_to_insert_resolved.document_id,
          CitationID,
          NOW(),
          NOW()
        FROM rows_to_insert_resolved
        RETURNING *
      ), inserted_citations_geo_entity AS (
        INSERT INTO document_citation_geo_entities (
          document_citation_id,
          geo_entity_id
        )
        SELECT
          inserted_citations.id,
          geo_entity_id
        FROM rows_to_insert_resolved
        JOIN inserted_citations ON inserted_citations.elib_legacy_id = rows_to_insert_resolved.CitationID
      )
      INSERT INTO document_citation_taxon_concepts (
        document_citation_id,
        taxon_concept_id
      )
      SELECT
        inserted_citations.id,
        splus_taxon_concept_id
      FROM rows_to_insert_resolved
      JOIN inserted_citations ON inserted_citations.elib_legacy_id = rows_to_insert_resolved.CitationID
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def all_rows_sql
    columns = %w(DocumentID CitationID CtyISO2 splus_taxon_concept_id)
    "SELECT #{columns.join(', ')} FROM #{table_name} t"
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_sql}
      ) all_rows_in_table_name
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

  def print_pre_import_stats
    print_citations_breakdown
    print_query_counts
  end

  def print_post_import_stats
    print_citations_breakdown
  end

  def print_citations_breakdown
    puts "#{Time.now} There are #{DocumentCitation.count} citations in total"
    DocumentCitation.includes(:document).group('documents.type').order('documents.type').count.each do |type, count|
      puts "\t #{type} #{count}"
    end
  end

end
