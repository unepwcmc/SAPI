class Species::EuListingChangeSerializer < Species::ListingChangeSerializer
  attributes :event_name, :event_url, :hash_full_note_en, :hash_display
end
