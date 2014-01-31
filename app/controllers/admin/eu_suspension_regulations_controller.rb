class Admin::EuSuspensionRegulationsController < Admin::EventsController
  #this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => EuSuspensionRegulation,
    :collection_name => 'eu_suspension_regulations', :instance_name => 'eu_suspension_regulation'

  def activate
    @eu_suspension_regulation = EuSuspensionRegulation.find(params[:id])
    @eu_suspension_regulation.activate!
    render 'create'
  end

  def deactivate
    @eu_suspension_regulation = EuSuspensionRegulation.find(params[:id])
    @eu_suspension_regulation.deactivate!
    render 'create'
  end

  protected
    def collection
      @eu_suspension_regulations ||= end_of_association_chain.
        order('designation_id ASC, events.effective_at DESC, events.name ASC').
        includes(:designation).
        page(params[:page]).
        search(params[:query])
    end

    def load_associations
      @eu_suspension_regulations_for_dropdown = EuSuspensionRegulation.
        where(:is_current => true).
        order('effective_at DESC')
    end

end
