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
      redirect_to @document.filename  # TODO refactor to open in new tab (FE needed?)
    elsif !File.exists?(path_to_file)
      render_404
    else
      # TODO refactor to open in new tab rather then download (FE needed?)
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

  def download_zip
    require 'zip'

    params[:taxon_concepts_ids] =
      if params[:taxon_name].present?
        # retrieve the same taxa as shown in the page
        MTaxonConcept.by_cites_eu_taxonomy
                     .without_non_accepted
                     .without_hidden
                     .by_name(
                        params[:taxon_name],
                        { :synonyms => true, :common_names => true, :subspecies => false }
                       )
                     .pluck(:id)
      elsif params[:taxon_concept_id].present?
        #retrieve all the children taxa given a taxon(included)
        descendants_ids(params[:taxon_concept_id])
      end

    docs = DocumentSearch.new(
      params.merge(show_private: !access_denied?, per_page: 10_000), 'public'
    )

    doc_ids = docs.cached_results.map { |doc| locale_document(doc) }.flatten
    doc_ids = doc_ids.map{ |d| d['id'] }

    @documents = Document.find(doc_ids.split(','))

    t = zip_file_generator

    send_file t.path,
      :type => "application/zip",
      :filename => "identifications-documents.zip"

    t.close
  end

  def volume_download
    require 'zip'

    docs = DocumentSearch.new(
      params.merge(show_private: !access_denied?, per_page: 10_000), 'public'
    )

    doc_ids = docs.cached_results.map { |doc| locale_document(doc) }.flatten
    doc_ids = doc_ids.map{ |d| d['id'] }

    @documents = Document.find(doc_ids.split(','))

    t = zip_file_generator #TODO move this to a background job

    send_file t.path,
      :type => "application/zip",
      :filename => "identifications-documents-volume.zip"

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

  def document_language_versions(doc)
    JSON.parse(doc.document_language_versions)
  end

  def locale_document(doc)
    document = document_language_versions(doc).select { |h| h['locale_document'] == 'true' }
    document = document_language_versions(doc).select { |h| h['locale_document'] == 'default' } if document.empty?
    document
  end

  def descendants_ids(taxon_concept)
    subquery = <<-SQL
      WITH RECURSIVE descendents AS (
        SELECT id
        FROM taxon_concepts_mview
        WHERE parent_id = #{taxon_concept.to_i}
        AND taxonomy_is_cites_eu = 't'
        AND name_status IN ('A', 'H')
        AND cites_show = 't'
        UNION ALL
        SELECT taxon_concepts.id
        FROM taxon_concepts_mview taxon_concepts
        JOIN descendents h ON h.id = taxon_concepts.parent_id
      )
      SELECT * FROM descendents
    SQL
    res = ActiveRecord::Base.connection.execute(subquery)
    res.ntuples.zero? ? [taxon_concept.to_i] : res.map(&:values).flatten << taxon_concept.to_i
  end

  def zip_file_generator
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
    t
  end
end
