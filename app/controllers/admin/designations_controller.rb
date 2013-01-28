class Admin::DesignationsController < Admin::SimpleCrudController

  def index
    @taxonomies = Taxonomy.order(:name)
    index!
  end

  def create
    @taxonomies = Taxonomy.order(:name)
    super
  end

  protected
    def collection
      @designations ||= end_of_association_chain.order(:name).page(params[:page])
    end
end

