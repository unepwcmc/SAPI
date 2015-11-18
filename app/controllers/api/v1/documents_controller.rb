class Api::V1::DocumentsController < ApplicationController

  def index

    if params[:taxon_concept_query].present?
      @species_search = Species::Search.new(params)
      params[:taxon_concepts_ids] = @species_search.results.map(&:id).join(',')
    end
    @search = DocumentSearch.new(params, 'public')

    documents = @search.results.order('date_raw DESC')

    documents = documents.where(is_public: "true") if access_denied?

    limit = 200
    cites_cop_docs = documents.where(event_type: "CitesCop")
    cites_cop_excluded = no_of_excluded_docs(cites_cop_docs, limit)
    ec_srg_docs = documents.where(event_type: "EcSrg")
    ec_srg_excluded = no_of_excluded_docs(ec_srg_docs, limit)
    cites_ac_docs = documents.where(event_type: "CitesAc")
    cites_ac_excluded = no_of_excluded_docs(cites_ac_docs, limit)
    cites_pc_docs = documents.where(event_type: "CitesPc")
    cites_pc_excluded = no_of_excluded_docs(cites_pc_docs, limit)
    # other docs can be docs tied to historic types of events (CITES Technical
    # Committe, CITES Extraordinary Meeting) or ones without event
    other_docs = documents.where(
      <<-SQL
        event_type IS NULL
        OR event_type NOT IN ('EcSrg', 'CitesCop', 'CitesAc', 'CitesPc')
      SQL
    )
    other_excluded = no_of_excluded_docs(other_docs, limit)

    render :json => {
      cites_cop: {
        docs: serialize_documents(cites_cop_docs, limit),
        excluded_docs: cites_cop_excluded,
      },
      ec_srg: {
        docs: serialize_documents(ec_srg_docs, limit),
        excluded_docs: ec_srg_excluded
      },
      cites_ac: {
        docs: serialize_documents(cites_ac_docs, limit),
        excluded_docs: cites_ac_excluded
      },
      cites_pc: {
        docs: serialize_documents(cites_pc_docs, limit),
        excluded_docs: cites_pc_excluded
      },
      other: {
        docs: serialize_documents(other_docs, limit),
        excluded_docs: other_excluded
      }
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

  def serialize_documents(documents, limit)
    ActiveModel::ArraySerializer.new(
      documents.limit(limit),
      each_serializer: Species::DocumentsSerializer
    )
  end

  def no_of_excluded_docs(documents, limit)
    excluded = documents.length - limit
    excluded < 0 ? 0 : excluded
  end

end
