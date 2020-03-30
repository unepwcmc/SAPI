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

  def download_zip
    require 'zip'

    doc_ids = MaterialDocIdsRetriever.run(params)

    @documents = Document.for_ids_with_order(doc_ids)

    @filename = params['taxon_name'] || MTaxonConcept.find(params['taxon_concept_id']).full_name

    t = merge_file_generator
    # t = zip_file_generator

    send_file t.path,
      :type => "application/zip",
      :filename => "Identifications-documents-#{@filename}.zip"
    t.close
  end

  def volume_download
    docs = DocumentSearch.new(
      params.merge(show_private: !access_denied?, per_page: 10_000), 'public'
    )

    doc_ids = docs.cached_results.map { |doc| locale_document(doc) }.flatten
    doc_ids = doc_ids.map{ |d| d['id'] }

    @documents = Document.find(doc_ids.split(',')).sort_by { |d| [d.volume, d.manual_id.downcase] }

    t = zip_file_generator #TODO move this to a background job

    volumes = params[:volume].sort.join(',')

    send_file t.path,
      :type => "application/zip",
      :filename => "Identifications-documents-volume-#{volumes}.zip"

    t.close

    File.delete(@merged_pdf_path)
  rescue SystemCallError => e
    puts e.message
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

  def merge_file_generator
    require 'zip'
# byebug
    t = Tempfile.new('tmp-zip-' + request.remote_ip)
    missing_files = []
    pdf_file_paths = []
    @merged_pdf_path = Rails.root.join("lib/files/merged_file_#{Time.now}.pdf")
    Zip::OutputStream.open(t.path) do |zos|
      @documents.each do |document|
        path_to_file = document.filename.path
        filename = path_to_file.split('/').last
        unless File.exists?(path_to_file)
          missing_files <<
            "{\n  title: #{document.title},\n  filename: #{filename}\n}"
        else
          pdf_file_paths << path_to_file
        end
      end
      PdfMerger.new(pdf_file_paths, @merged_pdf_path).merge
      zos.put_next_entry("Identification-materials-#{@filename}.pdf")
      zos.print IO.read(@merged_pdf_path)
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
