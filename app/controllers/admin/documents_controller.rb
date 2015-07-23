# /admin/event/:event_id/documents
# /admin/documents
class Admin::DocumentsController < Admin::StandardAuthorizationController
  belongs_to :event, optional: true

  def index
    load_associations
    @search = DocumentSearch.new(params)
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
      if @document.is_a?(Document::ReviewOfSignificantTrade)
        @document.review_details ||= Document::ReviewDetails.new
      elsif @document.is_a?(Document::Proposal)
        @document.proposal_details ||= Document::ProposalDetails.new
      end
      @document.citations.build
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

  protected

  def collection
    @documents = Kaminari::PaginatableArray.new(
      @search.cached_results,
      limit: @search.per_page,
      offset: @search.offset,
      total_count: @search.cached_total_cnt
    )
  end

  def load_associations
    @event_types = Event.elibrary_current_event_types.map(&:to_s)
    @events = Event.where(type: @event_types).order(:published_at).reverse_order
    @languages = Language.select([:id, :name_en, :name_es, :name_fr]).
     order(:name_en)
    @english = Language.find_by_iso_code1('EN')
    @taxonomy = Taxonomy.find_by_name(Taxonomy::CITES_EU)
    @geo_entities = GeoEntity.select(['geo_entities.id', :name_en]).
      joins(:geo_entity_type).where(
      :"geo_entity_types.name" => [GeoEntityType::COUNTRY, GeoEntityType::TERRITORY]
    ).order(:name_en)
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
