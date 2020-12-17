# /admin/event/:event_id/documents
# /admin/documents
class Admin::DocumentsController < Admin::StandardAuthorizationController

  def index
    load_associations
    is_secretariat = current_user && current_user.is_secretariat?
    @search = DocumentSearch.new(params.merge(show_private: !is_secretariat), 'admin')
    index! do
      if @search.events_ids.present? && @search.events_ids.length == 1
        @event = Event.find(@search.events_ids.first)
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
      format.html { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.html { success_redirect }
      failure.html do
        load_associations
        render 'new'
      end
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
    path_to_file = @document.filename.path unless @document.is_link?
    if @document.is_link?
      redirect_to @document.filename
    elsif !File.exists?(path_to_file)
      render :file => "#{Rails.root}/public/404.html", :status => 404
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

  def autocomplete
    title = params[:title]
    event_id = params[:event_id]
    @matched_documents = event_id.present? ? Document.where(event_id: event_id) : Document
    @matched_documents = @matched_documents.search_by_title(title)
    render :json => @matched_documents.to_json(
      :only => [:id, :title]
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
    @designations = Designation.where(name: ['CITES', 'EU']).select([:id, :name]).order(:name)
    @event_types =
      if @document && @document.event
        [{ id: @document.event.type }]
      else
        Event.event_types_with_names
      end
    @events = Event.where(type: @event_types.map { |t| t[:id] }).order(:published_at).reverse_order
    @event = Event.find(params[:event_id]) if params[:event_id].present?
    @languages = Language.select([:id, :name_en, :name_es, :name_fr]).
     order(:name_en)
    @english = Language.find_by_iso_code1('EN')
    @taxonomy = Taxonomy.find_by_name(Taxonomy::CITES_EU)
    @geo_entities = GeoEntity.select(['geo_entities.id AS id', :name_en]).
      joins(:geo_entity_type).where(
        :"geo_entity_types.name" => [GeoEntityType::COUNTRY, GeoEntityType::TERRITORY]
      ).order(:name_en)
  end

  def success_redirect
    redirect_to redirect_url, :notice => 'Operation succeeded'
  end

  def failure_redirect
    alert =
      if resource.errors.present?
        "Operation #{resource.errors.messages[:base].join(", ")}"
      else
        "Operation failed"
      end
    redirect_to redirect_url, :alert => alert
  end

  def redirect_url
    event_id = params[:event_id]
    url =
      if event_id.present?
        admin_event_documents_url(Event.find(event_id))
      else
        admin_documents_url
      end
  end
end
