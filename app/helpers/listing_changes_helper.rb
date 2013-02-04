module ListingChangesHelper
  def geo_entities_tooltip(listing_change)
    listing_change.geo_entities.map(&:name).join(', ')
  end
  def exclusions_tooltip(listing_change)
    listing_change.exclusions.map do |ex|
      tmp = ''
      puts ex.geo_entities.inspect
      if ex.taxon_concept
        tmp += "Except #{ex.taxon_concept.full_name}"
        if ex.geo_entities.count > 0
          tmp += "populations of #{geo_entities_tooltip(ex)}"
        end
      elsif ex.geo_entities.count > 0
        tmp += "Except populations of #{geo_entities_tooltip(ex)}"
      end
    end.join("\n")
  end
end