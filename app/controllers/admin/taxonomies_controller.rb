class Admin::TaxonomiesController < Admin::SimpleCrudController

  protected
    def collection
      @taxonomies ||= end_of_association_chain.order(:name).page(params[:page])
    end
end

