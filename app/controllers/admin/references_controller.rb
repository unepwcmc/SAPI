class Admin::ReferencesController < Admin::SimpleCrudController
  respond_to :json, :only => [:index, :update]

  def index
    index! do |format|
      format.json {
        render :text => end_of_association_chain.order(:title).
          select([:id, :title]).map{ |d| {:value => d.id, :text => d.title} }.to_json
      }
    end
  end

  def autocomplete
    @references = Reference.autocomplete(params[:query])
    @references.map! do |r|
      {
        :id => r.id,
        :value => "#{r.title} (#{r.author}, #{r.year})"
      }
    end

    render :json => @references.to_json
  end

  protected
    def collection
      @references ||= end_of_association_chain.order(:title).page(params[:page])
    end
end

