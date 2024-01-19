class UpdateNdfDocumentsToBePrivate < ActiveRecord::Migration
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
