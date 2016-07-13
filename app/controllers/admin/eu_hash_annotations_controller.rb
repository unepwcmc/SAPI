class Admin::EuHashAnnotationsController < Admin::HashAnnotationsController
  protected

  def load_collection
    end_of_association_chain.for_eu
  end

  def load_associations
    @events = EuRegulation.order(:effective_at)
  end

end
