##
# Make the filename column nullable on Document; after this, uploads will go
# into S3 storage rather than being kept on the disk of the web server.
#
# Note that the rollback 'down' migration is DESTRUCTIVE - all documents created
# since the change will be deleted, as they can no longer be represented in the
# previous schema.

class DocumentFilenameColumnDeprecated < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        change_column_null :documents, :filename, true
      end

      dir.down do
        invalid_documents = Document.where(filename: nil)

        if Rails.env.production? && invalid_documents.count > 0
          raise ActiveRecord::IrreversibleMigration,
            "This migration is destructive - it will delete #{
              invalid_documents.count
            } Documents."
        end

        # Just in case of a race condition...
        invalid_documents.destroy_all unless Rails.env.production?

        change_column_null :documents, :filename, false
      end
    end
  end
end
