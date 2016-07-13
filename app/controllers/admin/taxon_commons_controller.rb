class Admin::TaxonCommonsController < Admin::TaxonConceptAssociatedTypesController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept

  authorize_resource

  def new
    new! do |format|
      load_associations
      @taxon_common.build_common_name unless @taxon_common.common_name
    end
  end

  def create
    create! do |success, failure|
      success.js {
        @taxon_commons = @taxon_concept.taxon_commons
      }
      failure.js {
        load_associations
        render 'new'
      }
    end
  end

  def edit
    edit! do |format|
      load_associations
      format.js { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.js {
        @taxon_commons = @taxon_concept.taxon_commons
        render 'create'
      }
      failure.js {
        load_associations
        render 'new'
      }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_names_url(@taxon_concept),
          :notice => 'Operation succeeded'
      }
      failure.html {
        redirect_to admin_taxon_concept_names_url(@taxon_concept),
          :notice => 'Operation failed'
      }
    end
  end

  protected

  def load_associations
    @languages = Language.order(:name_en)
  end
end
