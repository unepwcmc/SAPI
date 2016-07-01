require Rails.root.join('lib/tasks/elibrary/importable.rb')
require Rails.root.join('lib/tasks/elibrary/citations_importer.rb')

class Elibrary::CitationsCopImporter < Elibrary::CitationsImporter

  def columns_with_type
    super() + [
      ['ProposalNo', 'TEXT'],
      ['ProposalNature', 'TEXT'],
      ['ProposalOutcome', 'TEXT'],
      ['ProposalAdditionalComments', 'TEXT'],
      ['ProposalHardCopy', 'TEXT'],
      ['ProposalRepresentation', 'TEXT'],
      ['ProposalOtherTaxonName', 'TEXT']
    ]
  end

  def run_preparatory_queries
    super()
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET ProposalNature = NULL WHERE ProposalNature='NULL'")
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET ProposalOutcome = NULL WHERE ProposalOutcome='NULL'")
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET ProposalRepresentation = NULL WHERE ProposalRepresentation='NULL'")

    # revert any previous CoP document duplication
    sql = <<-SQL
      WITH new_docs AS (
        SELECT id, original_id FROM documents
        WHERE type = 'Document::Proposal' AND original_id IS NOT NULL
      ), proposals AS (
        UPDATE proposal_details
        SET document_id = d.original_id
        FROM proposal_details pd
        JOIN new_docs d ON pd.document_id = d.id
        WHERE proposal_details.id = pd.id
      )
      DELETE FROM documents
      WHERE original_id IS NOT NULL;
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def run_final_queries
    # need to duplicate CoP documents, which are linked to more than one proposal
    # that applies to old documents
    sql = <<-SQL
      WITH proposal_details AS (
        SELECT proposal_details.*, ROW_NUMBER(*) OVER(PARTITION BY document_id)
        FROM proposal_details
      ), proposal_details_to_split AS (
        SELECT *
        FROM proposal_details
        WHERE row_number > 1
      ), documents_to_split AS (
        SELECT d.*
        FROM proposal_details_to_split pd
        JOIN documents d
        ON pd.document_id = d.id
      ), inserted_documents AS (
        INSERT INTO documents (
          event_id,
          sort_index,
          type,
          elib_legacy_id,
          title,
          date,
          filename,
          elib_legacy_file_name,
          is_public,
          language_id,
          created_at,
          updated_at,
          original_id
        )
        SELECT
          event_id,
          sort_index,
          type,
          elib_legacy_id,
          title,
          date,
          filename,
          elib_legacy_file_name,
          is_public,
          language_id,
          created_at,
          updated_at,
          id
        FROM documents_to_split d
        RETURNING *
      ), inserted_documents_with_rowno AS (
        SELECT *, ROW_NUMBER(*) OVER(PARTITION BY original_id)
        FROM inserted_documents
      ), proposal_details_to_update AS (
        SELECT pd.*, d.id AS new_document_id
        FROM proposal_details_to_split pd
        JOIN inserted_documents_with_rowno d
        ON d.original_id = pd.document_id AND (d.row_number + 1) = pd.row_number
      )
      UPDATE proposal_details
      SET document_id = new_document_id
      FROM proposal_details_to_update pd
      WHERE proposal_details.id = pd.id;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    # in case you need to revert
    # WITH new_docs AS (
    #   SELECT * FROM documents WHERE original_id IS NOT NULL
    # ), proposals AS (
    #   UPDATE proposal_details
    #   SET document_id = d.original_id
    #   FROM proposal_details pd
    #   JOIN new_docs d ON pd.document_id = d.id
    #   WHERE proposal_details.id = pd.id
    # )
    # DELETE FROM documents
    # WHERE original_id IS NOT NULL;

    sql = <<-SQL
      UPDATE documents
      SET title = COALESCE(pd.proposal_nature, title)
      FROM
      proposal_details pd
      WHERE documents.id = pd.document_id;
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def run_queries
    super()
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{proposal_details_rows_to_insert_sql}
      ), rows_to_insert_resolved AS (
        SELECT *, outcomes.id AS proposal_outcome_id, documents.id AS document_id
        FROM rows_to_insert
        JOIN documents ON DocumentID = documents.elib_legacy_id
        LEFT JOIN document_tags outcomes ON BTRIM(UPPER(outcomes.name)) = BTRIM(UPPER(ProposalOutcome))
      )
      INSERT INTO proposal_details(document_id, proposal_outcome_id, proposal_nature, representation, proposal_number, created_at, updated_at)
      SELECT document_id, proposal_outcome_id, ProposalNature, ProposalRepresentation, ProposalNo, NOW(), NOW()
      FROM rows_to_insert_resolved
    SQL
    ActiveRecord::Base.connection.execute(sql)
    run_final_queries
  end

  # this performs grouping, the proposal meta data used to be citation-level
  # but in the new system it is document-level
  def all_proposal_details_rows_sql
    <<-SQL
      SELECT CAST(DocumentID AS INT), ProposalNature, ProposalOutcome, ProposalRepresentation, ProposalNo
      FROM #{table_name}
      GROUP BY DocumentID, ProposalNature, ProposalOutcome, ProposalRepresentation, ProposalNo
    SQL
  end

  # this might return more than 1 row per DocumentID
  # it will lead to inserting multiple proposal_details records per document
  # that is not expected in the new structure; to work around the problem
  # after the import documents with multiple details will need to be duplicated
  def proposal_details_rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_proposal_details_rows_sql}
      ) all_rows_in_table_name
      WHERE ProposalNature IS NOT NULL
        OR ProposalOutcome IS NOT NULL
        OR ProposalRepresentation IS NOT NULL
      EXCEPT
      SELECT
        d.elib_legacy_id,
        dd.proposal_nature,
        outcomes.name,
        dd.representation,
        dd.proposal_number
      FROM (
        #{all_rows_sql}
      ) nc
      JOIN documents d ON d.elib_legacy_id = nc.DocumentID
      JOIN proposal_details dd ON d.id = dd.document_id
      JOIN document_tags outcomes ON dd.proposal_outcome_id = outcomes.id
    SQL
  end

end
