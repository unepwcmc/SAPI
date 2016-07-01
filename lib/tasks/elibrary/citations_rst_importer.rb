require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::CitationsRstImporter < Elibrary::CitationsImporter

  def columns_with_type
    super() + [
      ['SigTradePhase', 'TEXT'],
      ['SigTradeProcessStage', 'TEXT'],
      ['SigTradeDocumentNumber', 'TEXT'],
      ['SigTradeIntroduced', 'TEXT'],
      ['SigTradeMeeting1', 'TEXT'],
      ['SigTradeACMeetingDate1', 'TEXT'],
      ['SigTradeMeeting2', 'TEXT'],
      ['SigTradeCommitteeFirstDiscussed', 'TEXT'],
      ['SigTradeSignificantTradeReviewFor', 'TEXT'],
      ['SigTradeRegion1', 'TEXT'],
      ['SigTradeRegion2', 'TEXT'],
      ['SigTradeRegion3', 'TEXT'],
      ['SigTradeURL', 'TEXT'],
      ['SigTradeURL2', 'TEXT'],
      ['SigTradeHardCopyLocation', 'TEXT'],
      ['SigTradeFileName', 'TEXT'],
      ['SigTradePages', 'TEXT'],
      ['SigTradeLanguage', 'TEXT'],
      ['SigTradeIUCNConservationStatus', 'TEXT'],
      ['SigTradeIUCNConservationStatusCriteria', 'TEXT'],
      ['SigTradeAssessorsOfIUCNStatus', 'TEXT'],
      ['SigTradeDateOfIUCNAssessment', 'TEXT'],
      ['SigTradeRecommendedCategory', 'TEXT'],
      ['SigTradeNotes', 'TEXT'],
      ['SigTradeOtherDocumentInformation', 'TEXT'],
      ['SigTradeInitials', 'TEXT'],
      ['SigTradeTaxonID', 'TEXT']
    ]
  end

  def run_preparatory_queries
    super()
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET SigTradePhase = NULL WHERE SigTradePhase='NULL'")
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET SigTradeProcessStage = NULL WHERE SigTradeProcessStage='NULL'")
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET SigTradeRecommendedCategory = NULL WHERE SigTradeRecommendedCategory='NULL'")
  end

  def run_queries
    super()
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{review_details_rows_to_insert_sql}
      ), rows_to_insert_resolved AS (
        SELECT *, phases.id AS review_phase_id, stages.id AS process_stage_id, documents.id AS document_id
        FROM rows_to_insert
        JOIN documents ON DocumentID = documents.elib_legacy_id
        LEFT JOIN document_tags phases ON BTRIM(UPPER(phases.name)) = BTRIM(UPPER(SigTradePhase))
        LEFT JOIN document_tags stages ON BTRIM(UPPER(stages.name)) = BTRIM(UPPER(SigTradeProcessStage))
      )
      INSERT INTO review_details(document_id, review_phase_id, process_stage_id, recommended_category, created_at, updated_at)
      SELECT document_id, review_phase_id, process_stage_id, SigTradeRecommendedCategory, NOW(), NOW()
      FROM rows_to_insert_resolved
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  # this performs grouping, the review meta data used to be citation-level
  # but in the new system it is document-level
  def all_review_details_rows_sql
    <<-SQL
      SELECT CAST(DocumentID AS INT) AS DocumentID, SigTradePhase, SigTradeProcessStage, SigTradeRecommendedCategory
      FROM #{table_name}
      GROUP BY DocumentID, SigTradePhase, SigTradeProcessStage, SigTradeRecommendedCategory
    SQL
  end

  # this might return more than 1 row per DocumentID
  # it will lead to inserting multiple review_details records per document
  # that is not expected in the new structure; to work around the problem
  # after the import documents with multiple details will need to be duplicated
  def review_details_rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_review_details_rows_sql}
      ) all_rows_in_table_name
      WHERE SigTradePhase IS NOT NULL
        OR SigTradeProcessStage IS NOT NULL
        OR SigTradeRecommendedCategory IS NOT NULL
      EXCEPT
      SELECT
        d.elib_legacy_id,
        phases.name,
        stages.name,
        dd.recommended_category
      FROM (
        #{all_rows_sql}
      ) nc
      JOIN documents d ON d.elib_legacy_id = nc.DocumentID
      JOIN review_details dd ON d.id = dd.document_id
      JOIN document_tags phases ON dd.review_phase_id = phases.id AND phases.type = 'DocumentTag::ReviewPhase'
      JOIN document_tags stages ON dd.process_stage_id = stages.id AND stages.type = 'DocumentTag::ProcessStage'
    SQL
  end

end
