class Checklist::DocumentsController < ApplicationController

  def index
    return render :json => []  if params[:taxon_concepts_ids].nil?
    return render :json => []  unless params[:taxon_concepts_ids].kind_of?(Array)
    @search = DocumentSearch.new(
      params.merge(show_private: !access_denied?, per_page: 10_000), 'public'
    )

    render :json => @search.cached_results,
      each_serializer: Checklist::DocumentSerializer,
      meta: {
        total: @search.cached_total_cnt,
        page: @search.page,
        per_page: @search.per_page
      }
  end

  def show
    @document = Document.find(params[:id])
    path_to_file = @document.filename.path unless @document.is_link?
    if access_denied? && !@document.is_public
      render_403
    elsif @document.is_link?
      redirect_to @document.filename
    elsif !File.exists?(path_to_file)
      render_404
    else
      response.headers['Content-Length'] = File.size(path_to_file).to_s
      send_file(
        path_to_file,
          :filename => File.basename(path_to_file),
          :type => @document.filename.content_type,
          :disposition => 'attachment',
          :url_based_filename => true
      )
    end
  end

  def check_doc_presence
    doc_ids = MaterialDocIdsRetriever.run(params)

    render :json => doc_ids.present?
  end

  def volume_download
  require 'zip'

    doc_ids = MaterialDocIdsRetriever.run(params)

    @documents = Document.find(doc_ids.split(',')).sort_by { |d| [d.volume, d.manual_id.downcase] }

    t = zip_file_generator

    volumes = params[:volume].sort.join(',')

    send_file t.path,
      :type => "application/zip",
      :filename => "Identifications-documents-volume-#{volumes}.zip"

    t.close
  end

  private

  def access_denied?
    !current_user || current_user.is_api_user_or_secretariat?
  end

  def render_404
    render file: "#{Rails.root}/public/404", layout: false, formats: [:html],
    status: 404
  end

  def render_403
    render file: "#{Rails.root}/public/403", layout: false, formats: [:html],
    status: 403
  end

  def zip_file_generator
    t = Tempfile.new('tmp-zip-' + request.remote_ip)
    Zip::OutputStream.open(t.path) do |zos|
      @documents.each do |document|
        path_to_file = document.filename.path
        next unless File.exists?(path_to_file)
        filename = path_to_file.split('/').last
        zos.put_next_entry(filename)
        zos.print IO.read(path_to_file)
      end
    end
    t
  end
end
