class Api::V1::DocumentsController < ApplicationController

  def index

    if params[:taxon_concept_query].present?
      @species_search = Species::Search.new(params)
      params[:taxon_concepts_ids] = @species_search.results.map(&:id).join(',')
    end
    @search = DocumentSearch.new(params, 'public')

    documents = @search.results

    documents = documents.where(is_public: "true") if access_denied?

    cites_cop_docs = documents.where(event_type: "CitesCop")
    ec_srg_docs = documents.where(event_type: "EcSrg")
    cites_ac_docs = documents.where(event_type: "CitesAc")
    cites_pc_docs = documents.where(event_type: "CitesPc")
    # other docs can be docs tied to historic types of events (CITES Technical
    # Committe, CITES Extraordinary Meeting) or ones without event
    other_docs = documents.where(
      <<-SQL
        event_type IS NULL
        OR event_type NOT IN ('EcSrg', 'CitesCop', 'CitesAc', 'CitesPc')
      SQL
    )

    render :json => {
      cites_cop_docs: ActiveModel::ArraySerializer.new(cites_cop_docs, each_serializer: Species::DocumentsSerializer),
      ec_srg_docs: ActiveModel::ArraySerializer.new(ec_srg_docs, each_serializer: Species::DocumentsSerializer),
      cites_ac_docs: ActiveModel::ArraySerializer.new(cites_ac_docs, each_serializer: Species::DocumentsSerializer),
      cites_pc_docs: ActiveModel::ArraySerializer.new(cites_pc_docs, each_serializer: Species::DocumentsSerializer),
      other_docs: ActiveModel::ArraySerializer.new(other_docs, each_serializer: Species::DocumentsSerializer)
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
    Zip::OutputStream.open(t.path) do |zos|
      @documents.each do |document|
        path_to_file = document.filename.path
        unless File.exists?(path_to_file)
          render :file => "#{Rails.root}/public/404.html",  :status => 404  and return
        end
        zos.put_next_entry(path_to_file.split('/').last)
        zos.print IO.read(path_to_file)
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