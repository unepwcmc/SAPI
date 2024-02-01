class CmsMappingManager

  class << self

    def sync
      config_location ||= Rails.root.join('config/secrets.yml')
      @config = YAML.load_file(config_location)[Rails.env]
      index_url = @config['cms']['index']
      @show_url = @config['cms']['show']
      puts "#{index_url}"
      url = URI.escape(index_url)
      cms = Taxonomy.where(:name => Taxonomy::CMS).first
      species = JSON.parse(RestClient.get(url))
      species.each do |sp|
        taxon_concept = TaxonConcept.where(:full_name => sp["scientific_name"],
                                           :taxonomy_id => cms.id).first
        mapping = CmsMapping.find_or_create_by(
          taxon_concept_id: taxon_concept.try(:id), cms_taxon_name: sp["scientific_name"], cms_uuid: sp["node_uuid"])

        analyse mapping
      end
    end

    def analyse(mapping)
      url = URI.escape(@show_url + mapping.cms_taxon_name)
      species = JSON.parse(RestClient.get(url)).first
      if species
        puts "setting mapping details for #{mapping.cms_taxon_name}"
        mapping.cms_author = species["taxonomy"]["author"]
        taxon_concept = mapping.taxon_concept
        mapping.details = {
          'distributions_splus' => taxon_concept && taxon_concept.distributions.size,
          'distributions_cms' => species["geographic_range"]["range_states"].size,
          'instruments_splus' => taxon_concept && taxon_concept.instruments.map(&:name).join(", "),
          'instruments_cms' => species["assessment_information"].map do |ai|
            ai["instrument"] && ai["instrument"]["instrument"]
          end.join(", "),
          'listing_splus' => taxon_concept && taxon_concept.listing_changes.first &&
            "#{taxon_concept.listing_changes.first.species_listing.name}: #{taxon_concept.
              listing_changes.first.effective_at.strftime("%d/%m/%Y")}",
          'listing_cms' =>
            if species["appendix_1_date"]
              "Appendix I: #{Date.parse(species["appendix_1_date"]).strftime("%d/%m/%Y")}"
            elsif species["appendix_2_date"]
              "Appendix II: #{Date.parse(species["appendix_2_date"]).strftime("%d/%m/%Y")}"
            else
              nil
            end
        }
        mapping.save
      end
    end

    # Finds CITES' taxon concepts that match the CMS Species or Subspecies and
    # copies the distributions and distribution references from the CITES to the CMS taxon concept.
    # It also creates a taxon_relationship of EQUAL_TO between both taxon concepts
    def fill_cms_distributions
      species = Rank.where(:name => Rank::SPECIES).first
      subspecies = Rank.where(:name => Rank::SUBSPECIES).first
      cms = Taxonomy.where(:name => Taxonomy::CMS).first
      cites = Taxonomy.where(:name => Taxonomy::CITES_EU).first
      equal_to = TaxonRelationshipType.where(:name => TaxonRelationshipType::EQUAL_TO).first
      TaxonConcept.where(:rank_id => [species.id, subspecies.id],
                         :taxonomy_id => cms.id).each do |taxon|
        matching_cites_taxon = TaxonConcept.where(:rank_id => taxon.rank_id,
                                                  :full_name => taxon.full_name,
                                                  :taxonomy_id => cites.id).first
        next unless matching_cites_taxon
        puts "found a match for #{taxon.full_name} #{taxon.id} matches #{matching_cites_taxon.id}"
        matching_cites_taxon.distributions.each do |dist|
          distribution = Distribution.find_or_initialize_by(
            taxon_concept_id: taxon.id, geo_entity_id: ist.geo_entity_id)
          distribution.tag_list = dist.tag_list
          distribution.save
          dist.distribution_references.each do |reference|
            DistributionReference.find_or_create_by(
              distribution_id: distribution.id, reference_id: reference.reference_id)
          end
        end
        puts "creating taxon relationship"
        TaxonRelationship.create(:taxon_concept_id => matching_cites_taxon.id,
                                 :other_taxon_concept_id => taxon.id,
                                 :taxon_relationship_type_id => equal_to.id)
      end
    end
  end
end
