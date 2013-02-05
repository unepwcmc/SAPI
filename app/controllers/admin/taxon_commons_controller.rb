class Admin::TaxonCommonsController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept

  def new
    new! do |format|
      @languages = Language.order(:name_en)
      @taxon_common.build_common_name unless @taxon_common.common_name
    end
  end

  def create
    create! do |success, failure|
      failure.js {
        render 'new'
      }
    end
  end

  def edit
    edit! do |format|
      @languages = Language.order(:name_en)
      format.js { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.js { render 'create' }
      failure.js { render 'new' }
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

  def collection
    @taxon_commons ||= end_of_association_chain.
      includes(:common_name).page(params[:page])
  end
end

