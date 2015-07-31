class Api::V1::DocumentsController < ApplicationController

  def index

    documents = Document.from("api_documents_view adv").
      where("adv.taxon_concept_ids @> ARRAY[?]", params[:taxon_concept_id].to_i).
      select("adv.id, adv.event_name, adv.event_date, adv.event_type, adv.title, adv.is_public").order("adv.event_date DESC")

    public_only = !current_user || current_user.role == "api"

    documents = documents.where("adv.is_public = true") if public_only

    ec_srg_docs = documents.where("adv.event_type = 'EcSrg'")
    cites_cop_docs = documents.where("adv.event_type = 'CitesCop'")
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
      cites_cop_docs: ActiveModel::ArraySerializer.new(cites_cop_docs, each_serializer: Species::DocumentsSerializer),
      ec_srg_docs: ActiveModel::ArraySerializer.new(ec_srg_docs, each_serializer: Species::DocumentsSerializer),
      cites_ac_docs: ActiveModel::ArraySerializer.new(cites_ac_docs, each_serializer: Species::DocumentsSerializer),
      citec_pc_docs: ActiveModel::ArraySerializer.new(cites_pc_docs, each_serializer: Species::DocumentsSerializer),
      other_docs: ActiveModel::ArraySerializer.new(other_docs, each_serializer: Species::DocumentsSerializer)
    }
  end

  def show
    @document = Document.find(params[:id])
    send_file(
      @document.filename.path,
        :filename => File.basename(@document.filename.path),
        :type => @document.filename.content_type,
        :disposition => 'attachment',
        :url_based_filename => true
    )
  end

end
