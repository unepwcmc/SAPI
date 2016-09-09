class DownloadWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => false, :backtrace => 50

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
      I18n.locale = params[:locale] # because we're outside of request scope
      document_module = document_modules[@download.doc_type].new(params)

      @download.path     = document_module.generate
      @download.filename = document_module.download_name

      @download.display_name = Checklist::Checklist.summarise_filters(params)

      @download.status = "completed"

      @download.save!
    rescue => exception
      Appsignal.add_exception(exception) if defined? Appsignal
      @download.status = "failed"
      @download.save!
    end
  end
end
