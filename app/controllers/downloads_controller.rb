class DownloadsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  # GET downloads/
  #
  # Lists a set of downloads for a given list of IDs
  # TODO: if there is a current version of the download requested,
  # ignore the requested downloaded and return the cached current
  # version
  def index
    ids = params[:ids] || ""
    @downloads = Download.find(ids.split(","))

    render :json => @downloads
  end

  # POST downloads/
  def create
    @download = Download.create(params[:download])
    DownloadWorker.perform_async(@download.id, checklist_params)

    render :json => {downloads: [@download.attributes.except("filename", "path")]}
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
      send_file(@download.path,
        :filename => @download.filename,
        :type => "pdf")
    else
      render :json => {error: "Download not processed"}
    end
  end

  private

  def not_found
    render :json => {error: "No downloads available"}
  end

  # Returns a normalised list of parameters, with non-recognised params
  # removed.
  #
  # Array parameters are sorted for caching purposes.
  def checklist_params
    return {
      :scientific_name => params[:scientific_name] ? params[:scientific_name] : nil,
      :country_ids => params[:country_ids] ? params[:country_ids].sort : nil,
      :cites_region_ids =>
        params[:cites_region_ids] ? params[:cites_region_ids].sort : nil,
      :cites_appendices =>
        params[:cites_appendices] ? params[:cites_appendices].sort : nil,
      :output_layout =>
        params[:output_layout] ? params[:output_layout].to_sym : nil,
      :common_names =>
        [
          (params[:show_english] == '1' ? 'E' : nil),
          (params[:show_spanish] == '1' ? 'S' : nil),
          (params[:show_french] == '1' ? 'F' : nil)
        ].compact.sort,
      :synonyms => params[:show_synonyms] == '1',
      :authors => params[:show_author] == '1',
      :level_of_listing => params[:level_of_listing] == '1'
    }
  end

end
