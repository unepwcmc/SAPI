class AddElibLegacyIdToDocumentCitations < ActiveRecord::Migration
  def change
    add_column :document_citations, :elib_legacy_id, :integer
  end
end
