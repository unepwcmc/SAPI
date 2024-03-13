class AddElibLegacyIdToDocumentCitations < ActiveRecord::Migration[4.2]
  def change
    add_column :document_citations, :elib_legacy_id, :integer
  end
end
