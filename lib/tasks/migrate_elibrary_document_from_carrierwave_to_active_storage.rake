# lib/tasks/migrate_elibrary_document_from_carrierwave_to_active_storage.rake

namespace :documents do
  desc "Migrate CarrierWave :filename uploads (local disk) into ActiveStorage :file"
  task migrate_elibrary_document_from_carrierwave_to_active_storage: :environment do
    total = Document.count
    puts "Migrating #{total} documents…"

    Document.find_each.with_index(1) do |doc, idx|
      if doc.file.attached?
        puts "[#{idx}/#{total}] Skipping ##{doc.id}: already has ActiveStorage attachment"
        next
      end

      unless doc.filename.present? && doc.filename.path && File.exist?(doc.filename.path)
        puts "[#{idx}/#{total}] Skipping ##{doc.id}: no local CarrierWave file"
        next
      end

      file_path = doc.filename.path
      file_name = File.basename(file_path)

      File.open(file_path, 'rb') do |file_io|
        doc.file.attach(
          io: file_io,
          filename: file_name,
          content_type: Marcel::MimeType.for(file_io, name: file_name)
        )
      end

      puts "[#{idx}/#{total}] Migrated ##{doc.id} → ActiveStorage key=#{doc.file.key}"
    end

    puts "Done!"
  end
end
