class Admin::SimpleCrudController < Admin::AdminController
  inherit_resources
  respond_to :js, :only => [:create]
  respond_to :json, :only => [:update]

  def index
    load_associations
    index!
  end

  def create
    create! do |success, failure|
      success.js { render 'create' }
      failure.js do
        load_associations
        render 'new'
      end
    end
  end

  def update
    update! do |success, failure|
      success.js { render 'create' }
      failure.js do
        load_associations
        render 'new'
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to collection_url, :notice => 'Operation succeeded' }
      failure.html {
        redirect_to collection_url,
          :alert =>
            if resource.errors.present?
              "Operation #{resource.errors.messages[:base].join(", ")}"
            else
              "Operation failed"
            end
      }
    end
  end

  protected

  def load_associations; end

  def load_search
    load_taxonomies
    @taxon_concept ||= TaxonConcept.find(params[:taxon_concept_id])
    @search_params = SearchParams.new(
      {
        :taxonomy => { :id => @taxon_concept.taxonomy_id },
        :scientific_name => @taxon_concept.full_name,
        :name_status => @taxon_concept.name_status
      }
    )
  end

  def load_taxonomies
    @taxonomies ||= Taxonomy.order(:name)
  end

  def load_ranks
    @ranks = Rank.order(:taxonomic_position)
  end
end
