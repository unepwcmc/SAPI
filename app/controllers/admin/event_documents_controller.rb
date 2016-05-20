class Admin::EventDocumentsController < Admin::SimpleCrudController
  defaults :resource_class => Document,
    :collection_name => 'documents', :instance_name => 'document'
  belongs_to :event

  def show_order
    @event = Event.find(params[:event_id])
    @documents = DocumentCollectionOrder.new(@event.id).show
  end

  def update_order
    DocumentCollectionOrder.new(params[:event_id]).update(params[:documents])
    redirect_to show_order_admin_event_documents_url(event_id: params[:event_id])
  end
end
