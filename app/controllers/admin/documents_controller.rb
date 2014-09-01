# /admin/event/:event_id/documents
# /admin/documents
class Admin::DocumentsController < Admin::StandardAuthorizationController
  belongs_to :event, optional: true

  def index
    load_associations
    index! do
      if @event
        render 'admin/event_documents/index'
      else
        render 'index'
      end
      return
    end
  end

  def edit
    edit! do |format|
      load_associations
      @document.citations.build
      @taxonomy = Taxonomy.find_by_name(Taxonomy::CITES_EU)
      @geo_entities = GeoEntity.joins(:geo_entity_type).where(
        'geo_entity_types.name' => [GeoEntityType::COUNTRY, GeoEntityType::TERRITORY]
      )
      format.html { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.html { success_redirect }
      failure.html { load_associations; render 'new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { success_redirect }
      failure.html { failure_redirect }
    end
  end

  protected
  def collection
    @documents ||= end_of_association_chain.includes([:event, :language]).
      order(:date, :title).
      page(params[:page])

    @document_types = @documents.select(:type).map(&:type).uniq

    if !params['event-id-search'].nil? && params['event-id-search'] !=
     @event_type_search_prompt
      @documents = @documents.where("event_id = ?", params['event-id-search'])
    end
    if !params['document-title'].nil? && params['document-title'] !=
     @document_title_prompt
      @documents = @documents.where("title = ?", params['document-title'])
    end
    if !params['document-type'].nil? && params['document-type'] != ""
      @documents = @documents.where("documents.type = ?", params['document-type'])
    end

    @documents
  end

  def load_associations
    @event_types = ['CitesCop', 'CitesAc', 'CitesPc', 'EcSrg']
    @event_type_search_prompt = 'Select an event type...'
    @document_type_prompt = 'Select a document type...'
    @document_title_prompt = 'Enter a document title...'

    @event_type_query = params['event-type-search']
    @document_type_query = params['document-type']
    @document_title_query = params['document-title']

    @events = Event.where(type: @event_types).order(:effective_at).reverse_order
    @event_query_obj = ( params['event-id-search'] &&
     @events.find(params['event-id-search']) ) || @events.first

    @languages = Language.select([:id, :name_en, :name_es, :name_fr]).
     order(:name_en)
    @english = Language.find_by_iso_code1('EN')
    @is_query = !params['event-id-search'].nil? ||
     !params['document-type'].nil? || !params['document-title'].nil?
  end

  def success_redirect
    url = if @event
      admin_event_documents_url(@event)
    else
      admin_documents_url
    end
    redirect_to url, :notice => 'Operation succeeded'
  end

  def failure_redirect
    url = if @event
      admin_event_documents_url(@event)
    else
      admin_documents_url
    end
    alert = if resource.errors.present?
      "Operation #{resource.errors.messages[:base].join(", ")}"
    else
      "Operation failed"
    end
    redirect_to url, :alert => alert
  end

end
