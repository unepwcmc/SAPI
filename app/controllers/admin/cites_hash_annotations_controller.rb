class Admin::CitesHashAnnotationsController < Admin::HashAnnotationsController
  protected

  def load_collection
    end_of_association_chain.for_cites
  end

  def load_associations
    @events = CitesCop.order(:effective_at)
  end

end
