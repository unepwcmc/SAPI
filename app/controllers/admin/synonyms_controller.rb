class Admin::SynonymsController < Admin::SimpleCrudController
  defaults :resource_class => TaxonConcept, :collection_name => 'synonyms', :instance_name => 'synonym'
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept

  def new
    @designations = Designation.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    @synonym = TaxonConcept.new
    new! do |format|
      @synonym = TaxonConcept.new(
        :designation_id => @taxon_concept.designation_id,
        :rank_id => @taxon_concept.rank_id,
        :name_status => 'S'
      )
      @synonym.build_taxon_name
    end
  end

  def edit
    @designations = Designation.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    edit! do |format|
      @synonym = TaxonConcept.find(params[:id])
      format.js { render 'new' }
    end
  end

  def update
    @synonym = TaxonConcept.find(params[:id])
    update! do |success, failure|
      success.js { render 'create' }
      failure.js { render 'new' }
    end
  end

  def destroy
    @synonym = TaxonConcept.find(params[:id])
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
    @synonyms ||= end_of_association_chain.
      includes(:taxon_name).page(params[:page])
  end
end

