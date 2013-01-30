class Admin::TaxonConceptGeoEntitiesRelationshipsController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept

  def new
    new! do |format|
      @geo_entity = GeoEntity.find_by_name_en(params[:geo_entity])
      @taxon_concept = TaxonConcept.find_by_id(params[:taxon_concept_id])

      if (@geo_entity && @taxon_concept)
        @geo_entity_relationship = TaxonConceptGeoEntity.new(
          :geo_entity => geo_entity,
          :taxon_concept => taxon_concept
        )
        @geo_entity_relationship.tags = params[:"hidden-tags"] unless params[:"hidden-tags"].empty?
        @geo_entity_relationship.save!
      end
    end
  end

  def create
    create! do |success, failure|
      failure.js {
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
end
