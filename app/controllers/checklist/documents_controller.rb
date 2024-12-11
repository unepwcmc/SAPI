class Checklist::DocumentsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    return render json: []  if params[:taxon_concepts_ids].nil?
    return render json: []  unless params[:taxon_concepts_ids].kind_of?(Array)

    anc_ids = MaterialDocIdsRetriever.ancestors_ids(params[:taxon_concepts_ids].first)
    chi_ids = MTaxonConcept.descendants_ids(params[:taxon_concepts_ids].first).map(&:to_i)
    params[:taxon_concepts_ids] = anc_ids | chi_ids
    @search = DocumentSearch.new(
      params.merge(show_private: !access_denied?, per_page: 10_000), 'public'
    )

    render json: @search.cached_results,
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
      redirect_to @document.filename.model[:filename], allow_other_host: true
    elsif !File.exist?(path_to_file)
      render_404
    else
      response.headers['Content-Length'] = File.size(path_to_file).to_s

      send_file(
        path_to_file,
        filename: File.basename(path_to_file),
        type: @document.filename.content_type,
        disposition: 'attachment',
        url_based_filename: true
      )
    end
  end

  def check_doc_presence
    doc_ids = MaterialDocIdsRetriever.run(params.dup.permit!.to_h)

    render json: doc_ids.present?
  end

  ##
  # Produces and sends a zip file containing the ID manuals based on the
  # params `locale` and `volumes`, taken from `./public/ID_manual_volumes`.
  # The Document::IdManual and Language must exist in the database.
  def volume_download
    # We are building a path, so we must ensure that this is safe. to_i is
    # sufficient.
    volumes = Array.wrap(
      params['volume']
    ).map(&:to_i).filter(&:positive?).sort.uniq

    # First, ensure the language exists. Default to the current
    language = Language.find_by!(
      iso_code1: (params['locale'] || I18n.locale)&.to_s&.upcase
    )

    documents = Document::IdManual.where(
      # If volumes is empty, get all volumes (expressed as `volume >= 1`)
      volume: volumes.presence || (1..),
      language: language.id
    )

    if documents.size < volumes.size
      raise ActiveRecord::RecordNotFound(
        primary_key: 'volume',
        id: documents.pluck(:volumes) - volumes,
        model: Document::IdManual,
      )
    end

    temp_zip_file = full_volume_downloader(
      volumes: documents.pluck(:volume),
      language_code: language.iso_code1,
      temp_file: Tempfile.new(
        'tmp-zip-' + request.remote_ip.to_s.gsub(/\W+/, '-')
      )
    )

    unless temp_zip_file
      render_404
      return
    end

    begin
      volumes_list = volumes.join(',')

      send_file temp_zip_file.path,
        type: 'application/zip',
        filename: "Identifications-documents-volume-#{volumes_list}.zip"
    ensure
      temp_zip_file.close
    end
  end

private

  def access_denied?
    !current_user || current_user.is_api_user_or_secretariat?
  end

  def render_404
    render file: "#{Rails.public_path.join('404.html')}",
      layout: false,
      formats: [ :html ],
      status: :not_found
  end

  def render_403
    render file: "#{Rails.public_path.join('403.html')}",
      layout: false,
      formats: [ :html ],
      status: :forbidden
  end

  ##
  # Returns a zip archive with one or more volumes of the CITES ID manuals.
  #
  # If no files are found, returns null. If some files are found, a list
  # of missing files is added to the archive.
  def full_volume_downloader(
    ##
    # An array of integers, corresponding to the "volume" column
    volumes = [],
    ##
    # A two-letter ISO language code
    language_code = I18n.default_locale.to_s.upcase,
    ##
    # The file into which a zip archive will be written
    temp_file = Tempfile.new
  )
    missing_files = []

    vol_path = "ID_manual_volumes/#{language_code.downcase}"

    ##
    # An array of Pathname objects
    @pdf_file_paths =
      volumes.map do |vol|
        Rails.public_path.join(
          "#{vol_path}/Volume#{vol}_#{language_code}.pdf"
        )
      end

    Zip::OutputStream.open(temp_file.path) do |zos|
      @pdf_file_paths.each do |doc_path|
        path_to_file = doc_path.dirname
        filename = doc_path.basename

        unless File.exist?(doc_path)
          missing_files <<
            "{\n  path: #{path_to_file},\n  filename: #{filename}\n}"
        else
          zos.put_next_entry("Identification-materials-#{filename}")
          zos.print File.read(doc_path)
        end

        if missing_files.present?
          if missing_files.length == @pdf_file_paths.count
            return
          end

          zos.put_next_entry('missing_files.txt')
          zos.print missing_files.join("\n\n")
        end
      end
    end

    temp_file
  end
end
