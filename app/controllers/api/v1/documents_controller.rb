class Api::V1::DocumentsController < ApplicationController

  def index
    if params[:taxon_concept_query].present?
      @species_search = Species::Search.new({
        visibility: 'elibrary',
        taxon_concept_query: params[:taxon_concept_query]
      })
      params[:taxon_concepts_ids] = @species_search.results.map(&:id).join(',')
    end
    @search = DocumentSearch.new(
      params.merge(show_private: !access_denied?, per_page: 100), 'public'
    )

    render :json => @search.cached_results,
      each_serializer: Species::DocumentSerializer,
      meta: {
        total: @search.cached_total_cnt,
        page: @search.page,
        per_page: @search.per_page
      }
  end

  def show
    @document = Document.find(params[:id])
    path_to_file = @document.filename.path;
    if access_denied? && !@document.is_public
      render :file => "#{Rails.root}/public/403.html",  :status => 403
    elsif !File.exists?(path_to_file)
      render :file => "#{Rails.root}/public/404.html",  :status => 404
    else
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
          render :file => "#{Rails.root}/public/404.html",  :status => 404  and return
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
    !current_user || current_user.role == User::API_USER
  end

end
