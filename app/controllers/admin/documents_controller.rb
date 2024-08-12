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

  def show
    @document = Document.find(params[:id])
    path_to_file = @document.filename.path unless @document.is_link?
    if @document.is_link?
      redirect_to @document.filename.model[:filename]
    elsif !File.exist?(path_to_file)
      render file: "#{Rails.public_path.join('404.html')}", status: :not_found
    else
      send_file(
        path_to_file,
        filename: File.basename(path_to_file),
        type: @document.filename.content_type,
        disposition: 'attachment',
        url_based_filename: true
      )
    end
  end
  def edit
    edit! do |format|
      load_associations
      if @document.is_a?(Document::ReviewOfSignificantTrade)
        @document.review_details ||= ReviewDetails.new
      elsif @document.is_a?(Document::Proposal)
        @document.proposal_details ||= ProposalDetails.new
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


  def autocomplete
    title = params[:title]
    event_id = params[:event_id]
    @matched_documents = event_id.present? ? Document.where(event_id: event_id) : Document
    @matched_documents = @matched_documents.search_by_title(title)
    render json: @matched_documents.to_json(
      only: [ :id, :title ]
    )
  end

  protected

  def collection
    # Super hacky. Pagination has been disabled in the DocumentSearch class
    # for some reason related to the API documents endpoint and a 'new cascading feature'.
    # As a result ~8000 records are returned in the results part of the Kaminari::PaginatableArray,
    # triggering > 15000 database calls in the view.
    # Here I am using the pagination initialized on the search class to paginate the results,
    # so for both the web and API actions, pagination is broken in the search class and
    # retrofitted in the controllers.
    # TO DO: figure out if the cascading feature has been completed, and if so move the
    # pagination back into the search class and out of the controllers.
    @documents = Kaminari::PaginatableArray.new(
      # @search.cached_results.limit(@search.per_page).offset(@search.offset).to_a,
      # Leonardo: rollback https://github.com/unepwcmc/SAPI/commit/52f6439bdd05ce8bbf4e5121c2a8af427668b079
      # cached_results return array, not ActiveRecord Relation, cannot chain to use .limit(), etc.
      @search.cached_results,
      limit: @search.per_page,
      offset: @search.offset,
      total_count: @search.cached_total_cnt
    )
  end

  def load_associations
    @designations = Designation.where(name: [ 'CITES', 'EU' ]).select([ :id, :name ]).order(:name)
    @event_types =
      if @document && @document.event
        [ { id: @document.event.type } ]
      else
        Event.event_types_with_names
      end
    @events = Event.where(type: @event_types.pluck(:id)).order(:published_at).reverse_order
    @event = Event.find(params[:event_id]) if params[:event_id].present?
    @languages = Language.select([ :id, :name_en, :name_es, :name_fr ]).
      order(:name_en)
    @english = Language.find_by(iso_code1: 'EN')
    @taxonomy = Taxonomy.find_by(name: Taxonomy::CITES_EU)
    @geo_entities = GeoEntity.select([ 'geo_entities.id AS id', :name_en ]).
      joins(:geo_entity_type).where(
        'geo_entity_types.name': [ GeoEntityType::COUNTRY, GeoEntityType::TERRITORY ]
      ).order(:name_en)
  end

  def success_redirect
    redirect_to redirect_url, notice: 'Operation succeeded'
  end

  def failure_redirect
    alert =
      if resource.errors.present?
        "Operation #{resource.errors.messages[:base].join(", ")}"
      else
        'Operation failed'
      end
    redirect_to redirect_url, alert: alert
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

  private

  def document_params
    params.require(:document).permit(
      # attributes were in model `attr_accessible`.
      :event_id, :filename, :date, :type, :title, :is_public,
      :language_id,
      :sort_index, :discussion_id, :discussion_sort_index,
      :primary_language_document_id,
      :designation_id,
      citations_attributes: [
        :id, :_destroy, :document_id, :stringy_taxon_concept_ids,
        geo_entity_ids: []
      ],
      proposal_details_attributes: [
        :id, :_destroy, :document_id, :proposal_nature, :proposal_outcome_id,
        :representation, :proposal_number
      ],
      review_details_attributes: [
        :id, :_destroy, :document_id, :review_phase_id, :process_stage_id, :recommended_category
      ]
    )
  end
end
