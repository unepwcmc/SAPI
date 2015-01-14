class Species::EuListingChangeSerializer < Species::ListingChangeSerializer
  attributes :event_name, :event_url, :hash_full_note_en, :hash_display,
    :nomenclature_note_en, :nomenclature_note_fr, :nomenclature_note_es
end
