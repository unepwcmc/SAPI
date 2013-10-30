module ListingChangesHelper
  def geo_entities_tooltip(listing_change)
    listing_change.geo_entities.map(&:name).join(', ')
  end

  def excluded_geo_entities_tooltip(listing_change)
    listing_change.excluded_geo_entities.map(&:name).join(', ')
  end

  def annotation_tooltip(listing_change)
    if listing_change.annotation
      "#{listing_change.annotation.short_note} (#{listing_change.annotation.full_note})"
    end
  end

  def hash_annotation_tooltip(listing_change)
    if listing_change.hash_annotation
      listing_change.hash_annotation.full_note_en
    end
  end

end
