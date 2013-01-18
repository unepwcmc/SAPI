class Admin::ListingChangesController < Admin::SimpleCrudController

  belongs_to :taxon_concept, :optional => true

  protected
  def collection
    @listing_changes ||= end_of_association_chain.
      order('effective_at desc, is_current desc').
      page(params[:page])
  end
end
