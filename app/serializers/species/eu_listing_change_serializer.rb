class Species::EuListingChangeSerializer < ActiveModel::Serializer
  attributes :is_current, :species_listing_name, :party_full_name,
   :effective_at_formatted, :short_note_en, :full_note_en,
   :change_type_name, :event_name

  def event_name
    object.listing_change.event.try(:name)
  end
end
