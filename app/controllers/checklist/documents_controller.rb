class Checklist::DocumentsController < ApplicationController

  def index
    return render :json => []  if params[:taxon_concepts_ids].nil?
    return render :json => []  unless params[:taxon_concepts_ids].kind_of?(Array)
    anc_ids = MaterialDocIdsRetriever.ancestors_ids(params[:taxon_concepts_ids].first)
    chi_ids = MTaxonConcept.descendants_ids(params[:taxon_concepts_ids].first).map(&:to_i)
    params[:taxon_concepts_ids] = anc_ids | chi_ids
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

    t = full_volume_downloader

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

  def full_volume_downloader
    require 'zip'

    t = Tempfile.new('tmp-zip-' + request.remote_ip)
    missing_files = []
    vol_path = [Rails.root, '/public/ID_manual_volumes/', params['locale'], '/'].join
    @pdf_file_paths = params['volume'].map { |vol| vol_path + "Volume#{vol}" + "_#{params['locale'].upcase}" + '.pdf' }
    Zip::OutputStream.open(t.path) do |zos|
      @pdf_file_paths.each do |doc_path|
        path_to_file = doc_path.rpartition('/').first
        filename = doc_path.rpartition('/').last
        unless File.exists?(doc_path)
          missing_files <<
            "{\n  path: #{path_to_file},\n  filename: #{filename}\n}"
        else
          zos.put_next_entry("Identification-materials-#{filename}")
          zos.print IO.read(doc_path)
        end
        if missing_files.present?
          if missing_files.length == @pdf_file_paths.count
            render_404 && return
          end
          zos.put_next_entry('missing_files.txt')
          zos.print missing_files.join("\n\n")
        end
      end
    end
    t
  end
end
