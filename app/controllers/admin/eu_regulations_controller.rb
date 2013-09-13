class Admin::EuRegulationsController < Admin::EventsController
  #this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => EuRegulation,
    :collection_name => 'eu_regulations', :instance_name => 'eu_regulation'

  def activate
    @eu_regulation = EuRegulation.find(params[:id])
    @eu_regulation.activate!
    render 'create'
  end

  protected
    def collection
      @eu_regulations ||= end_of_association_chain.
        order(:designation_id, :name).includes(:designation).
        page(params[:page]).
        search(params[:query])
    end

    def load_associations
      @eu_regulations_for_dropdown = EuRegulation.order(:effective_at)
    end

end
