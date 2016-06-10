class Admin::ListingChangesController < Admin::StandardAuthorizationController
  belongs_to :eu_regulation

  protected

  def collection
    @listing_changes ||= end_of_association_chain.
      includes([
        :species_listing,
        :change_type,
        :party_geo_entity,
        :geo_entities,
        :annotation,
        :taxon_concept,
        :exclusions => [:geo_entities, :taxon_concept]
      ]).
      where("change_types.name <> '#{ChangeType::EXCEPTION}'").
      page(params[:page]).per(200).where(:parent_id => nil).
      order('taxon_concepts.full_name ASC, listing_changes.effective_at DESC').
      search(params[:query])
  end
end
