class Api::V1::DocumentsController < ApplicationController

  def index
    if params[:taxon_concept_query].present?
      exact_match = MTaxonConcept.where("LOWER(full_name) = ?", params[:taxon_concept_query].downcase)
                                 .where(taxonomy_id: 1)
                                 .first
      @species_search = Species::Search.new({
        visibility: :elibrary,
        taxon_concept_query: params[:taxon_concept_query]
      })
      ids = @species_search.ids.join(',')
      params[:taxon_concepts_ids] = MaterialDocIdsRetriever.ancestors_ids(ids, params[:taxon_concept_query], exact_match).uniq # @species_search.ids.join(',')
    else
      if params[:taxon_concepts_ids].present?
        taxa = TaxonConcept.find(params[:taxon_concepts_ids])
        children_ids = taxa.map(&:children).map do
          |children| children.pluck(:id) if children.present?
        end.flatten.uniq.compact
        taxa_ids = taxa.map(&:id)
        ancestor_ids = MaterialDocIdsRetriever.ancestors_ids(taxa_ids.first)
        params[:taxon_concepts_ids] = taxa_ids | ancestor_ids | children_ids
      end
    end

    @search = DocumentSearch.new(
      params.merge(show_private: !access_denied?, per_page: 100), 'public'
    )

    #TODO move pagination and ordering to the document_search module after refactoring of SQL mviews
    page = params[:page] || 1
    per_page = params[:per_page] || 100
    offset = per_page * (page.to_i - 1)

    ordered_docs =
      if params[:taxon_concepts_ids].present?
        @search.cached_results.sort_by do |doc|
          doc_tc_ids = doc.taxon_concept_ids.gsub(/[{}]/, '').split(',').map(&:to_i)
          params[:taxon_concepts_ids].index{ |id| doc_tc_ids.include?(id) } || 1_000_000
        end
      else
        @search.cached_results.limit(per_page).offset(offset)
      end

    ordered_docs =
      Kaminari.paginate_array(ordered_docs).page(page).per(per_page) if ordered_docs.kind_of?(Array)

    render :json => ordered_docs,
      each_serializer: Species::DocumentSerializer,
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
          :disposition => 'inline',
          :url_based_filename => true
      )
    end
  end

  def download_zip
    require 'zip'

    @documents = Document.find(params[:ids].split(','))

    t = Tempfile.new('tmp-zip-' + request.remote_ip)
    missing_files = []
    Zip::OutputStream.open(t.path) do |zos|
      @documents.each do |document|
        path_to_file = document.filename.path
        filename = path_to_file.split('/').last
        unless File.exists?(path_to_file)
          missing_files <<
            "{\n  title: #{document.title},\n  filename: #{filename}\n}"
        else
          zos.put_next_entry(filename)
          zos.print IO.read(path_to_file)
        end
      end
      if missing_files.present?
        if missing_files.length == @documents.count
          render_404 && return
        end
        zos.put_next_entry('missing_files.txt')
        zos.print missing_files.join("\n\n")
      end
    end

    send_file t.path,
      :type => "application/zip",
      :filename => "elibrary-documents.zip"

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

end
