class Admin::DistributionsController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept

  def new
    new! do |format|
      @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
              where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
    end
  end

  def edit
    edit! do |format|
      @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
              where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
      format.js { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.js { render 'create' }
      failure.js { render 'new' }
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
