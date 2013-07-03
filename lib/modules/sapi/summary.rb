module Sapi
module Summary

  def database_summary
    puts "#############################################################"
    puts "#################                  ##########################"
    puts "################# Database Summary ##########################"
    puts "#################                  ##########################"
    puts "#############################################################\n"
    print_count_for "Taxonomies", Taxonomy.count
    print_count_for "Designations", Designation.count
    print_count_for "Ranks", Rank.count
    print_count_for "TaxonName", TaxonName.count
    print_count_for "GeoEntityTypes", GeoEntityType.count
    print_count_for "GeoEntities", GeoEntity.count
    print_count_for "Countries", GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => {:name => GeoEntityType::COUNTRY}).count
    print_count_for "CITES Regions", GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => {:name => GeoEntityType::CITES_REGION}).count
    print_count_for "References", Reference.count
    print_count_for "CommonNames", CommonName.count
    print_count_for "English CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'English'}).count
    print_count_for "French CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'French'}).count
    print_count_for "Spanish CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'Spanish'}).count
    print_count_for "Total TaxonConcepts", TaxonConcept.count
    Taxonomy.where(:name => 'CITES_EU').each do |t|
      puts "#############################################################"
      puts "Details for Taxa under #{t.name}"
      animals_ids = TaxonConcept.where(:taxonomy_id => t.id, :name_status => 'A', :legacy_type => 'Animalia').select('id').map(&:id)
      plants_ids = TaxonConcept.where(:taxonomy_id => t.id, :name_status => 'A', :legacy_type => 'Plantae').select('id').map(&:id)
      puts ">>> Animalia general stats"
      print_count_for "accepted", animals_ids.count
      print_count_for "non accepted nor synonyms", TaxonConcept.where(:taxonomy_id => t.id, :legacy_type => 'Animalia').where("name_status NOT IN ('A', 'S')").count
      print_count_for "Listing Changes", ListingChange.where(:taxon_concept_id => animals_ids).count
      print_count_for "Distributions", Distribution.where(:taxon_concept_id => animals_ids).count
      print_count_for "TaxonCommons", TaxonCommon.where(:taxon_concept_id => animals_ids).count
      print_count_for "Synonyms", TaxonConcept.where(:taxonomy_id => t.id, :name_status => 'S', :legacy_type => 'Animalia').count
      puts ">>> Plantae general stats"
      print_count_for "Accepted", plants_ids.count
      print_count_for "non accepted nor synonyms", TaxonConcept.where(:taxonomy_id => t.id, :legacy_type => 'Plantae').where("name_status NOT IN ('A', 'S')").count
      print_count_for "Listing Changes", ListingChange.where(:taxon_concept_id => plants_ids).count
      print_count_for "Distributions", Distribution.where(:taxon_concept_id => plants_ids).count
      print_count_for "TaxonCommons", TaxonCommon.where(:taxon_concept_id => plants_ids).count
      print_count_for "Synonyms", TaxonConcept.where(:taxonomy_id => t.id, :name_status => 'S', :legacy_type => 'Plantae').count

      puts "###################### #{t.name} ############################"
      puts "Break down per Rank"
      puts "#############################################################"
      Rank.order(:taxonomic_position).each do |r|
        puts "##############   Rank: #{r.name} ####################"
        ranked_animals_ids = TaxonConcept.where(:id => animals_ids, :rank_id => r.id).select(:id).map(&:id)
        ranked_plants_ids = TaxonConcept.where(:id => plants_ids, :rank_id => r.id).select(:id).map(&:id)
        puts ">>> Animalia rank stats"
        print_count_for "Taxa", ranked_animals_ids.count
        print_count_for " Listing Changes", ListingChange.where(:taxon_concept_id => ranked_animals_ids).count
        puts ">>> Plantae rank stats"
        print_count_for "Taxa", ranked_plants_ids.count
        print_count_for "Listing Changes", ListingChange.where(:taxon_concept_id => ranked_plants_ids).count
        puts "#####################################################"
      end
    end
  end

  def print_count_for klass, count
    puts "#{count} #{klass} in the Database. #{if count == 0 then " !!!!!!!!!!!!!!!!!!!!!!! ZERO !!!!!!!!!!!!!!!!!!!!!!! " end}"
  end

end
end