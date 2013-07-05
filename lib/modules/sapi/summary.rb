module Sapi
  module Summary

    def self.database_summary
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
      Taxonomy.all.each { |t| taxonomy_summary(t) }
    end

    def self.taxonomy_summary(t)
      puts "#############################################################"
      puts "Details for Taxa under #{t.name}"
      TaxonConcept.joins(:rank).where(
        :"ranks.name" => Rank::KINGDOM, :taxonomy_id => t.id
      ).each do |k|
        kingdom_summary(t, k)
      end
    end

    def self.kingdom_summary(t, k)
      puts "#############################################################"
      puts ">>> #{k.full_name} general stats"
      taxon_concept_ids = TaxonConcept.where(
        :taxonomy_id => t.id, 
        :name_status => 'A').
      where(["(data->'kingdom_id')::INT = ?", k.id]).select('id').map(&:id)

      print_count_for "Accepted", taxon_concept_ids.count
      print_count_for "Synonyms", TaxonConcept.where(
        :taxonomy_id => t.id, :name_status => 'S'
      ).where(["(data->'kingdom_id')::INT = ?", k.id]).count
      print_count_for "Neither accepted nor synonyms", TaxonConcept.where(
        :taxonomy_id => t.id
      ).where(["(data->'kingdom_id')::INT = ?", k.id]).
      where("name_status NOT IN ('A', 'S')").count
      print_count_for "Listing Changes", ListingChange.where(
        :taxon_concept_id => taxon_concept_ids
      ).count
      print_count_for "Distributions", Distribution.where(
        :taxon_concept_id => taxon_concept_ids
      ).count
      print_count_for "TaxonCommons", TaxonCommon.where(
        :taxon_concept_id => taxon_concept_ids
      ).count
      
      Rank.order(:taxonomic_position).each do |r|
        puts "##############   Rank: #{r.name} ####################"
        ranked_taxon_concept_ids = TaxonConcept.where(
          :id => taxon_concept_ids, :rank_id => r.id
        ).select(:id).map(&:id)     
        print_count_for "Taxa", ranked_taxon_concept_ids.count
        print_count_for " Listing Changes", ListingChange.where(
          :taxon_concept_id => ranked_taxon_concept_ids
        ).count
      end     
      puts "#####################################################"
    end

    def self.print_count_for klass, count
      puts "#{count} #{klass} in the Database. #{if count == 0 then " !!!!!!!!!!!!!!!!!!!!!!! ZERO !!!!!!!!!!!!!!!!!!!!!!! " end}"
    end

  end
end