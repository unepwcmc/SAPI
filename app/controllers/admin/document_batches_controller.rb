# /admin/event/:event_id/document_batch
# /admin/document_batch
class Admin::DocumentBatchesController < Admin::StandardAuthorizationController

  def new
    load_associations
    @document_batch = DocumentBatch.new(
      event_id: @event.try(:id),
      date: @event.try(:effective_at_formatted),
      language_id: @english.id,
      is_public: false,
      documents: [Document.new]
    )
  end

  def create
    @event = Event.find(params[:event_id]) if params[:event_id]
    @document_batch = DocumentBatch.new(document_batch_params)
    if @document_batch.save
      if @event
        redirect_to admin_event_documents_url(@event)
      else
        redirect_to admin_documents_url
      end
    else
      load_associations
      render 'new'
    end
  end

  protected

  def load_associations
    @event = Event.find(params[:event_id]) if params[:event_id]
    @languages = Language.select([:id, :name_en, :name_es, :name_fr]).order(:name_en)
    @english = Language.find_by_iso_code1('EN')
    @document_types = if @event
      @event.class.document_types.map { |l| [l.display_name, l] }
    else
      ['Document', 'Document'] # TODO other non-event types
    end
  end

  def document_batch_params
    params.require(:document_batch).permit(
      :event_id, :date, :language_id, :is_public,
      :documents_attributes => [
        :type,
        :filename,
        :_destroy
      ]
    )
  end

end
