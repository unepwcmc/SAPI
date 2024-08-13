class Admin::DistributionsController < Admin::TaxonConceptAssociatedTypesController
  respond_to :js, only: [ :new, :edit, :create, :update ]
  belongs_to :taxon_concept
  before_action :load_tags_and_geo_entities, only: [ :new, :edit ]
  before_action :load_search, only: [ :index ]

  def index
    @distributions = @taxon_concept.distributions.joins(
      :geo_entity
    ).order(
      Arel.sql('UPPER(geo_entities.name_en) ASC')
    )
  end

  def edit
    edit! do |format|
      format.js { render 'new' }
    end
  end

  def create
    create! do |success, failure|
      success.js do
        load_distributions
        if params['reference']['id'].present?
          @distribution.add_existing_references(params['reference']['id'])
        end
      end
      failure.js do
        load_tags_and_geo_entities
        render 'new'
      end
    end
  end
  def update
    update! do |success, failure|
      success.js do
        load_distributions
        if params['reference']['id'].present?
          @distribution.add_existing_references(params['reference']['id'])
        end
        render 'create'
      end
      failure.js do
        load_tags_and_geo_entities
        render 'new'
      end
    end
  end


  def destroy
    destroy! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_distributions_url(@taxon_concept),
          notice: 'Operation succeeded'
      end
      failure.html do
        redirect_to admin_taxon_concept_distributions_url(@taxon_concept),
          notice: 'Operation failed'
      end
    end
  end

protected

  def load_tags_and_geo_entities
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(is_current: true,
        geo_entity_types: { name: GeoEntityType::SETS[GeoEntityType::DEFAULT_SET] }
      )
    @tags = PresetTag.where(model: PresetTag::TYPES[:Distribution])
  end

  def load_distributions
    @distributions = @taxon_concept.distributions.
      joins(:geo_entity).order('geo_entities.name_en ASC')
  end

private

  def distribution_params
    params.require(:distribution).permit(
      # attributes were in model `attr_accessible`.
      :geo_entity_id, :taxon_concept_id, :internal_notes, :created_by_id, :updated_by_id,
      references_attributes: [ :citation, :created_by_id, :updated_by_id, :id, :_destroy ],
      tag_list: []
    )
  end
end
