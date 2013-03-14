module ListingChangesHelper
  def geo_entities_tooltip(listing_change)
    listing_change.geo_entities.map(&:name).join(', ')
  end

  def exclusions_tooltip(listing_change)
    taxonomic_exceptions_str = 'Except: ' +
      listing_change.taxonomic_exclusions.map do |ex|
        tmp = ex.taxon_concept.full_name
        if ex.geo_entities.count > 0
          tmp += " populations of: #{geo_entities_tooltip(ex)}"
        end
        tmp
      end.join(', ') if listing_change.taxonomic_exclusions.count > 0

    geographic_exceptions_str = 'Except populations of: ' +
      listing_change.geographic_exclusions.map{ |ex| geo_entities_tooltip(ex) }.
        join(', ') if listing_change.geographic_exclusions.count > 0

    [taxonomic_exceptions_str, geographic_exceptions_str].compact.join('; ')
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