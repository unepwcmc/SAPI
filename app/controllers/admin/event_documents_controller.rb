class Admin::EventDocumentsController < Admin::SimpleCrudController
  authorize_resource :class => 'Document'
  defaults :resource_class => Document,
    :collection_name => 'documents', :instance_name => 'document'
  belongs_to :event
  respond_to :js, :only => [:edit]

  def index
    load_associations
    index! do
      @document_batch ||= DocumentBatch.new(
        event_id: @event.id,
        date: @event.effective_at_formatted,
        language_id: @english.id,
        is_public: false,
        documents: [Document.new]
      )
    end
  end

  def edit
    edit! do |format|
      load_associations
      format.js { render 'new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to admin_event_documents_url(@event), :notice => 'Operation succeeded' }
      failure.html {
        redirect_to admin_event_documents_url(@event),
          :alert => if resource.errors.present?
              "Operation #{resource.errors.messages[:base].join(", ")}"
            else
              "Operation failed"
            end
      }
    end
  end

  def upload
  	@event = Event.find(params[:event_id]) #TODO can this be set by inherited resources?
    @document_batch = DocumentBatch.new(document_batch_params)
    if @document_batch.save
      redirect_to(admin_event_documents_url(@event))
    else
      load_associations
      render 'index'
    end
  end

  protected

  def collection
    @documents ||= end_of_association_chain.includes(:language).
      order(:title).
      page(params[:page])
  end

  def load_associations
    @languages = Language.select([:id, :name_en, :name_es, :name_fr]).order(:name_en)
    @english = Language.find_by_iso_code1('EN')
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
