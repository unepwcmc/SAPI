class Api::V1::DocumentsController < ApplicationController

  def index
    documents = Document.from("api_documents_view adv").
      where("adv.taxon_concept_ids @> ARRAY[?]", params[:taxon_concept_id].to_i).
      select("adv.id, adv.event_name, adv.event_date, adv.event_type, adv.title")

    cites_cop_docs = documents.where("adv.event_type = 'CitesCop'")
    ec_srg_docs = documents.where("adv.event_type = 'EcSrg'")
    cites_ac_docs = documents.where("adv.event_type = 'CitesAC'")
    cites_pc_docs = documents.where("adv.event_type = 'CitesPC'")
    no_event_docs = documents.where("adv.event_type = 'NoEvent'")

    render :json => {
      cites_cop_docs: ActiveModel::ArraySerializer.new(cites_cop_docs, each_serializer: Species::DocumentsSerializer),
      ec_srg_docs: ActiveModel::ArraySerializer.new(ec_srg_docs, each_serializer: Species::DocumentsSerializer),
      cites_ac_docs: ActiveModel::ArraySerializer.new(cites_ac_docs, each_serializer: Species::DocumentsSerializer),
      citec_pc_docs: ActiveModel::ArraySerializer.new(cites_pc_docs, each_serializer: Species::DocumentsSerializer),
      no_event_docs: ActiveModel::ArraySerializer.new(no_event_docs, each_serializer: Species::DocumentsSerializer)
    }
  end
end
