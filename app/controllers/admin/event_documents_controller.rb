class Admin::EventDocumentsController < Admin::SimpleCrudController
  defaults :resource_class => Document,
    :collection_name => 'documents', :instance_name => 'document'
  belongs_to :event

  def reorder
    @event = Event.find(params[:event_id])
    @documents = Document.from('api_documents_mview documents').
      select([:id, :title, :proposal_number, :document_type, :language]).
      where(event_id: @event.id).
      where('primary_document_id = id').
      order(:sort_index)
  end
end
