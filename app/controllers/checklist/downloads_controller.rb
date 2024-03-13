class Checklist::DownloadsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  # GET downloads/
  #
  # Lists a set of downloads for a given list of IDs
  def index
    ids = params[:ids] || ""
    @downloads = Download.where(:id => ids).order('updated_at DESC').limit(5)
    @downloads = @downloads.map { |v| v.attributes.except("filename", "path") }
    @downloads.each do |v|
      v["updated_at"] = v["updated_at"].strftime("%A, %e %b %Y %H:%M")
    end

    render :json => @downloads.to_json
  end

  # Permissions are not checked here, therefore CSRF is redundant.
  # Requests are triggered from the CITES checklist which has no means of
  # generating adequate CSRF protection.
  skip_before_action :verify_authenticity_token, only:[:create]

  # POST downloads/
  def create
    @download = Download.create(download_params)
    if download_params[:doc_type] == 'citesidmanual'
      ManualDownloadWorker.perform_async(@download.id, params.dup.permit!.to_h)
    else
      DownloadWorker.perform_async(@download.id, params.dup.permit!.to_h)
    end

    @download = @download.attributes.except("filename", "path")
    @download["updated_at"] = @download["updated_at"].strftime("%A, %e %b %Y %H:%M")

    render :json => @download.to_json
  end

  # GET downloads/:id/
  def show
    @download = Download.find(params[:id])

    render :json => { status: @download.status }
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
      render :json => { error: "Download not processed" }
    end
  end

  def download_index
    @doc = download_module::Index.new(checklist_params)
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
    render :json => { error: "No downloads available" }
  end

  def download_params
    params.require(:download).permit(
      # attributes used in this controller.
      :doc_type,
      # other attributes were in model `attr_accessible`.
      :format
    )
  end

  def checklist_params
    Checklist::ChecklistParams.sanitize(
      params
    )
  end
end
