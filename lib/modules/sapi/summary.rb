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
      print_count_for "Instruments", Instrument.count
      print_count_for "Ranks", Rank.count
      print_count_for "TaxonName", TaxonName.count
      print_count_for "GeoEntityTypes", GeoEntityType.count
      print_count_for "GeoEntities", GeoEntity.count
      print_count_for "Countries", GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => {:name => GeoEntityType::COUNTRY}).count
      print_count_for "CITES Regions", GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => {:name => GeoEntityType::CITES_REGION}).count
      print_count_for "Territories", GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => {:name => GeoEntityType::TERRITORY}).count
      print_count_for "References", Reference.count
      print_count_for "Taxon Concept References", TaxonConceptReference.count
      print_count_for "Taxon Concept Standard References", TaxonConceptReference.where(:is_standard => true).count
      print_count_for "Distribution References", DistributionReference.count
      print_count_for "CommonNames", CommonName.count
      print_count_for "English CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'English'}).count
      print_count_for "French CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'French'}).count
      print_count_for "Spanish CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'Spanish'}).count
      print_count_for "Total TaxonConcepts", TaxonConcept.count
      puts ""
      print_count_for "Quotas", Quota.count
      print_count_for "CITES Suspensions", CitesSuspension.count
      print_count_for "EU Opinions", EuOpinion.count
      print_count_for "EU Suspensions", EuSuspension.count
      puts ""
      print_count_for "Terms", Term.count
      print_count_for "Sources", Source.count
      print_count_for "Units", Unit.count
      print_count_for "Purpose", Purpose.count
      puts ""
      Taxonomy.all.each { |t| taxonomy_summary(t) }
    end

    def self.taxonomy_summary(t)
      puts "#############################################################"
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
      puts "#############################################################"
      puts ">>> #{k.full_name} general stats"

      print_count_for "Accepted", TaxonConcept.where(
          :taxonomy_id => t.id, 
          :name_status => 'A').
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      print_count_for "Synonyms", TaxonConcept.where(
        :taxonomy_id => t.id, :name_status => 'S'
      ).where(["(data->'kingdom_id')::INT = ?", k.id]).count
      print_count_for "Neither accepted nor synonyms", TaxonConcept.where(
        :taxonomy_id => t.id
      ).where(["(data->'kingdom_id')::INT = ?", k.id]).
      where("name_status NOT IN ('A', 'S')").count
      print_count_for "Listing Changes", ListingChange.joins(:taxon_concept).
        where(:taxon_concepts => {:taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      distributions = Distribution.joins(:taxon_concept).
        where(:taxon_concepts => {:taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id])
      print_count_for "Distributions", distributions.count
      print_count_for "Distribution Tags", ActiveRecord::Base.connection.execute(<<-SQL
            SELECT COUNT(*) FROM taggings
              INNER JOIN distributions ON
                taggings.taggable_id = distributions.id AND
                taggings.taggable_type = 'Distribution'
              INNER JOIN taxon_concepts ON
                distributions.taxon_concept_id = taxon_concepts.id 
                AND taxon_concepts.taxonomy_id = #{t.id}
                AND (data->'kingdom_id')::INT = #{k.id};
           SQL
        ).values.flatten[0]
      print_count_for "Distribution References", DistributionReference.
        joins(:distribution => :taxon_concept).
        where(:taxon_concepts => {:taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      print_count_for "Taxon Concept References", TaxonConceptReference.joins(:taxon_concept).
        where(:taxon_concepts => {:taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      print_count_for "Taxon Concept Standard References", TaxonConceptReference.joins(:taxon_concept).
        where(:taxon_concepts => {:taxonomy_id => t.id }, :taxon_concept_references => {:is_standard => true}).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      print_count_for "TaxonCommons", TaxonCommon.joins(:taxon_concept).
        where(:taxon_concepts => {:taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count

      puts ""
      Rank.order(:taxonomic_position).each do |r|
        puts "##############   Rank: #{r.name} ####################"
        ranked_taxon_concept_ids = TaxonConcept.
          where(:taxonomy_id => t.id, :rank_id => r.id).
          where(["(data->'kingdom_id')::INT = ?", k.id]).
          select(:id).map(&:id)
        print_count_for "Taxa", ranked_taxon_concept_ids.count
        print_count_for " Listing Changes", ListingChange.where(
          :taxon_concept_id => ranked_taxon_concept_ids
        ).count
      end
      puts "#####################################################"
      puts ""
    end

    def self.print_count_for klass, count
      puts "#{count} #{klass}"
    end

  end
end
