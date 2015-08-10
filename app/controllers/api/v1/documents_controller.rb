class Api::V1::DocumentsController < ApplicationController

  def index

    documents = Document.from("api_documents_view adv").select("*").
      where("adv.taxon_concept_ids @> ARRAY[?]", params[:taxon_concept_id].to_i).order("adv.event_date DESC")

    documents = documents.where("adv.is_public = true") if access_denied?

    ec_srg_docs = documents.where("adv.event_type = 'EcSrg'")
    cites_cop_docs = Document.find_by_sql(get_documents_by_sql)
    cites_ac_docs = documents.where("adv.event_type = 'CitesAc'")
    cites_pc_docs = documents.where("adv.event_type = 'CitesPc'")
    # other docs can be docs tied to historic types of events (CITES Technical
    # Committe, CITES Extraordinary Meeting) or ones without event
    other_docs = documents.where(
      <<-SQL
      adv.event_type IS NULL
      OR adv.event_type NOT IN ('EcSrg', 'CitesCop', 'CitesAc', 'CitesPc')
      SQL
    )

    render :json => {
      cites_cop_docs: cites_cop_docs,
      ec_srg_docs: ActiveModel::ArraySerializer.new(ec_srg_docs, each_serializer: Species::DocumentsSerializer),
      cites_ac_docs: ActiveModel::ArraySerializer.new(cites_ac_docs, each_serializer: Species::DocumentsSerializer),
      citec_pc_docs: ActiveModel::ArraySerializer.new(cites_pc_docs, each_serializer: Species::DocumentsSerializer),
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

  private

  def get_documents_by_sql event_type=nil
    <<-SQL
      SELECT event_name, event_date, event_type,is_public, document_type,
        number, sort_index, proposal_outcome, primary_document_id,
        geo_entity_names, taxon_names,
        ARRAY_TO_JSON(
          ARRAY_AGG_NOTNULL(
            ROW(
              documents.id, documents.title, language
            )::document_language_version
          )
        ) AS document_language_versions
      FROM (
        SELECT *
        FROM api_documents_view
        WHERE taxon_concept_ids @> ARRAY[4521]
      ) documents
      GROUP BY event_name, event_date, event_type, is_public, document_type,
        number, sort_index, proposal_outcome, primary_document_id,
        geo_entity_names, taxon_names
    SQL
  end

  def access_denied?
    !current_user || current_user.role == User::API_USER
  end

end
