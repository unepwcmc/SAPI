module ListingChangesHelper
  def geo_entities_tooltip(listing_change)
    listing_change.geo_entities.map(&:name).join(', ')
  end
  def exclusions_tooltip(listing_change)

    taxonomic_exceptions, geographic_exceptions = 
      listing_change.exclusions.order('taxon_concept_id').
      partition{ |item| !item.taxon_concept.nil? }

    taxonomic_exceptions_str = 'Except: ' +
      taxonomic_exceptions.map do |ex|
        tmp = ex.taxon_concept.full_name
        if ex.geo_entities.count > 0
          tmp += "populations of #{geo_entities_tooltip(ex)}"
        end
        tmp
      end.join(', ') if taxonomic_exceptions.count > 0

    geographic_exceptions_str = 'Except populations of' +
      geographic_exceptions.map{ |ex| geo_entities_tooltip(ex) }.
        join(', ') if geographic_exceptions.count > 0

    "#{taxonomic_exceptions_str} #{geographic_exceptions_str}"

    # listing_change.exclusions.order('taxon_concept_id').map do |ex|
      # tmp = ''
      # puts ex.inspect
      # puts ex.geo_entities.inspect
      # if ex.taxon_concept
        # tmp += "Except #{ex.taxon_concept.full_name}"
        # if ex.geo_entities.count > 0
          # tmp += "populations of #{geo_entities_tooltip(ex)}"
        # end
      # elsif ex.geo_entities.count > 0
        # tmp += "Except populations of #{geo_entities_tooltip(ex)}"
      # end
      # tmp
    # end.join("\n")
  end
end