class DownloadZipJob < ApplicationJob
  DOWNLOAD_FILENAME = 'elibrary-documents.zip'.freeze
  ZIP_CONTENT_TYPE = 'application/zip'.freeze

  def perform(download_zip_id)
    download_zip = DownloadZip.find(download_zip_id)

    if download_zip.status == DownloadZip::COMPLETED && download_zip.zip_file.attached?
      return
    end

    # This job owns the eventual ZIP generation lifecycle. Marking the record
    # as processing here makes the asynchronous state transition explicit
    # before we add the actual Active Storage artifact creation.
    download_zip.update!(
      status: DownloadZip::PROCESSING,
      processing_at: Time.current,
      error_message: nil
    )

    attached_documents, missing_files = selected_documents(download_zip.document_ids)
    raise 'No documents available to generate ZIP' if attached_documents.empty?

    Tempfile.create([ download_zip.checksum, '.zip' ]) do |tempfile|
      build_zip_archive(tempfile:, documents: attached_documents, missing_files:)

      File.open(tempfile.path, 'rb') do |zip_file|
        # `Zip::OutputStream` writes through a separate file handle, so we must
        # reopen the finished archive for attachment. Reusing the original
        # `Tempfile` handle here can produce a blob without a persisted
        # attachment in this app/test setup.
        download_zip.zip_file.attach(
          io: zip_file,
          filename: DOWNLOAD_FILENAME,
          content_type: ZIP_CONTENT_TYPE
        )

        # Active Storage persists attachments immediately for a clean,
        # persisted record. If we dirty the model first, the attachment gets
        # queued in memory and can be dropped by the later save, which leaves
        # a "completed" row without any downloadable file.
        download_zip.update!(
          status: DownloadZip::COMPLETED,
          completed_at: Time.current,
          error_message: nil
        )
      end
    end
  rescue => exception
    Appsignal.add_exception(exception) if defined? Appsignal

    download_zip&.update(
      status: DownloadZip::FAILED,
      error_message: exception.message
    )

    raise exception
  end

private

  def selected_documents(document_ids)
    documents_by_id = Document.where(id: document_ids).index_by(&:id)

    attached_documents = []
    missing_files = []

    document_ids.each do |document_id|
      document = documents_by_id[document_id]

      unless document
        missing_files << missing_document_entry(
          title: "Document #{document_id} no longer exists",
          filename: 'Unavailable'
        )
        next
      end

      unless document.file.attached?
        missing_files << missing_document_entry(
          title: document.title,
          filename: document.filename
        )
        next
      end

      attached_documents << document
    end

    [ attached_documents, missing_files ]
  end

  def build_zip_archive(tempfile:, documents:, missing_files:)
    Zip::OutputStream.open(tempfile.path) do |zip_stream|
      documents.each do |document|
        zip_stream.put_next_entry(document.file.filename.to_s)

        document.file.blob.service.download(document.file.blob.key) do |chunk|
          zip_stream.write(chunk)
        end
      end

      next if missing_files.empty?

      zip_stream.put_next_entry('missing_files.txt')
      zip_stream.write(missing_files.join("\n\n"))
    end
  end

  def missing_document_entry(title:, filename:)
    "{\n  title: #{title},\n  filename: #{filename}\n}"
  end
end
