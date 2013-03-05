class DownloadWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => false

  def perform(download_id, params)
    @download = Download.find(download_id)

    begin
      format_modules = {
        'pdf' => Checklist::Pdf,
        'csv' => Checklist::Csv,
        'json' => Checklist::Json
      }

      format_module = format_modules[@download.format]

      document_modules = {
        'index'   => format_module::Index,
        'history' => format_module::History
      }

      params = params.symbolize_keys
      document_module = document_modules[@download.doc_type].new(params)

      @download.filename = document_module.download_name
      @download.path     = document_module.generate

      @download.display_name = Checklist::Checklist.summarise_filters(params)

      @download.status = "completed"

      @download.save!
    rescue => msg
      puts "Failed: #{msg}"
      puts "### Backtrace ###"
      puts msg.backtrace
      @download.status = "failed"
      @download.save!
    end
  end
end
