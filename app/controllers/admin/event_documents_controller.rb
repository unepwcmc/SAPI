class Admin::EventDocumentsController < Admin::SimpleCrudController
  defaults :resource_class => Document,
    :collection_name => 'documents', :instance_name => 'document'
  belongs_to :event

  def show_order
    @event = Event.find(params[:event_id])
    @documents = Document.
      joins('LEFT JOIN languages ON languages.id = documents.language_id').
      joins('LEFT JOIN proposal_details ON proposal_details.document_id = documents.id').
      select(
        "documents.id AS id,
        title,
        proposal_details.proposal_number AS proposal_number,
        type,
        languages.iso_code1 AS language"
      ).
      where(event_id: @event.id).
      where('primary_language_document_id IS NULL OR primary_language_document_id = documents.id').
      order(:sort_index)
  end

  def update_order
    params[:documents].each do |id, sort_index|
      Document.update_all({sort_index: sort_index}, {id: id})
    end
    DocumentSearch.refresh
    redirect_to show_order_admin_event_documents_url(event_id: params[:event_id])
  end
end
