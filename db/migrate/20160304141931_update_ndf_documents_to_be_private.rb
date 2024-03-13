class UpdateNdfDocumentsToBePrivate < ActiveRecord::Migration[4.2]
  def change
    ApplicationRecord.connection.execute(
      <<-SQL
        UPDATE documents
        SET is_public = false
        WHERE type = 'Document::NonDetrimentFindings' OR type = 'Document::NdfConsultation'
      SQL
    )
  end
end
