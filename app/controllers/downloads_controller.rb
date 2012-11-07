class DownloadsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  # GET downloads/
  #
  # Lists a set of downloads for a given list of IDs
  def index
    ids = params[:ids] || ""
    @downloads = Download.find(ids.split(","))

    @downloads.map! { |v| v.attributes.except("filename", "path") }
    @downloads.each do |v|
      v["updated_at"] = v["updated_at"].strftime("%A, %e %b %Y %H:%M")
    end

    render :json => @downloads
  end

  # POST downloads/
  def create
    @download = Download.create(params[:download])
    DownloadWorker.perform_async(@download.id, params)

    render :json => @download.attributes.except("filename", "path")
  end

  # GET downloads/:id/
  def show
    @download = Download.find(params[:id])

    render :json => {status: @download.status}
  end

  # GET downloads/:id/download
  def download
    @download = Download.find(params[:id])

    if @download.status == Download::COMPLETED
      # Update access time for cache cleaning purposes
      FileUtils.touch(@download.path)

      send_file(@download.path,
        :filename => @download.filename,
        :type => "pdf")
    else
      render :json => {error: "Download not processed"}
    end
  end

  def download_index
    download_module = {
      "pdf" => Checklist::Pdf,
      "csv" => Checklist::Csv,
      "json" => Checklist::Json
    }

    doc = download_module[params[:format]]::Index.new(params)
    @download_path = doc.generate
    send_file(@download_path,
      :filename => doc.download_name,
      :type => doc.ext)
  end

  def download_history
    download_module = {
      "pdf" => Checklist::Pdf,
      "csv" => Checklist::Csv,
      "json" => Checklist::Json
    }

    doc = download_module[params[:format]]::History.new(params)
    @download_path = doc.generate
    send_file(@download_path,
      :filename => doc.download_name,
      :type => doc.ext)
  end

  private

  def not_found
    render :json => {error: "No downloads available"}
  end

end
