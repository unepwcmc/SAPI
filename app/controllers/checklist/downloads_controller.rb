class Checklist::DownloadsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  # GET downloads/
  #
  # Lists a set of downloads for a given list of IDs
  def index
    ids = params[:ids] || ""
    @downloads = Download.where(:id => ids).order('updated_at DESC').limit(5)
    @downloads.map! { |v| v.attributes.except("filename", "path") }
    @downloads.each do |v|
      v["updated_at"] = v["updated_at"].strftime("%A, %e %b %Y %H:%M")
    end

    render :text => @downloads.to_json
  end

  # POST downloads/
  def create
    @download = Download.create(params[:download])
    if params[:download][:doc_type] == 'citesidmanual'
      ManualDownloadWorker.perform_async(@download.id, params)
    else
      DownloadWorker.perform_async(@download.id, params)
    end

    @download = @download.attributes.except("filename", "path")
    @download["updated_at"] = @download["updated_at"].strftime("%A, %e %b %Y %H:%M")

    render :text => @download.to_json
  end

  # GET downloads/:id/
  def show
    @download = Download.find(params[:id])

    render :text => { status: @download.status }.to_json
  end

  # GET downloads/:id/download
  def download

    @download = Download.find(params[:id])

    if @download.status == Download::COMPLETED
      # Update access time for cache cleaning purposes
      FileUtils.touch(@download.path)
      # this was added in order to prevent download managers from
      # failing when chunked_transfer_encoding is set in nginx (1.8.1)
      file_path = Pathname.new(@download.path).realpath
      response.headers['Content-Length'] = File.size(file_path).to_s
      send_file(file_path,
        :filename => @download.filename,
        :type => @download.format)
    else
      render :text => { error: "Download not processed" }.to_json
    end
  end

  def download_index
    @doc = download_module::Index.new(params)
    send_download
  end

  def download_history
    @doc = download_module::History.new(params)
    send_download
  end

  private

  def download_module
    format_mapping = {
      "pdf" => Checklist::Pdf,
      "csv" => Checklist::Csv,
      "json" => Checklist::Json
    }
    format_mapping[params[:format]] || Checklist::Pdf
  end

  def send_download
    @download_path = @doc.generate
    # this was added in order to prevent download managers from
    # failing when chunked_transfer_encoding is set in nginx (1.8.1)
    file_path = Pathname.new(@download_path).realpath
    response.headers['Content-Length'] = File.size(file_path).to_s
    send_file(file_path,
      :filename => @doc.download_name,
      :type => @doc.ext)
  end

  def not_found
    render :text => { error: "No downloads available" }.to_json
  end

end
