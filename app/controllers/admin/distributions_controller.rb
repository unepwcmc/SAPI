class Admin::DistributionsController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept
  before_filter :load_tags_and_geo_entities, :only => [:new, :edit]

  def edit
    edit! do |format|
      format.js { render 'edit' }
    end
  end

  def update
    update! do |success, failure|
      success.js { 
        load_distributions
        render 'create' 
      }
      failure.js {
        load_tags_and_geo_entities
        render 'new' 
      }
    end
  end

  def create
    create! do |success, failure|
      success.js {
        load_distributions
        unless params["reference"]["id"].blank?
          @references = params["reference"]["id"]
          @reference_ids = @references.split(",")

          @reference_ids.each do |r|
            reference = Reference.find(r)

            unless reference.nil?
              distribution_reference = DistributionReference.new({
                :distribution_id => @distribution.id,
                :reference_id => reference.id
              }).save!
            end
          end
        end
      }
      failure.js {
        load_tags_and_geo_entities
        render 'new'
      }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to edit_admin_taxon_concept_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
      failure.html {
        redirect_to edit_admin_taxon_concept_url(params[:taxon_concept_id]),
        :notice => 'Operation failed'
      }
    end
  end

  protected
  def load_tags_and_geo_entities
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
            where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
    @tags = PresetTag.where(:model => PresetTag::TYPES[:Distribution])
  end

  def load_distributions
    @distributions = @taxon_concept.distributions.
      joins(:geo_entity).order('geo_entities.name_en ASC')
  end
end
