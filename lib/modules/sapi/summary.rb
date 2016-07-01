module Sapi
  module Summary

    def self.database_stats
      stats = {}
      stats[:core] = self.core_stats
      stats[:taxonomic] = self.taxonomic_stats
      stats[:geo] = self.geo_stats
      stats[:refs] = self.references_stats
      stats[:trade] = self.trade_stats
      stats[:trade_restrictions] = self.trade_restrictions_stats
      stats[:cites_eu] = {}
      stats[:cites_eu][:animalia] = self.taxonomy_kingdom_stats Taxonomy::CITES_EU, 'Animalia'
      stats[:cites_eu][:plantae] = self.taxonomy_kingdom_stats Taxonomy::CITES_EU, 'Plantae'
      stats[:cms] = self.taxonomy_kingdom_stats Taxonomy::CMS, 'Animalia'
      stats
    end

    def self.core_stats
      core = {}
      core[:taxonomies] = Taxonomy.count
      core[:designations] = Designation.count
      core[:instruments] = Instrument.count
      core[:languages] = Language.count
      core
    end

    def self.taxonomic_stats
      taxonomic = {}
      taxonomic[:ranks] = Rank.count
      taxonomic[:taxon_names] = TaxonName.count
      taxonomic[:taxon_concepts] = TaxonConcept.count
      taxonomic[:common_names] = CommonName.count
      taxonomic[:common_names_en] = CommonName.joins(:language).where(:languages => { :name_en => 'English' }).count
      taxonomic[:common_names_fr] = CommonName.joins(:language).where(:languages => { :name_en => 'French' }).count
      taxonomic[:common_names_es] = CommonName.joins(:language).where(:languages => { :name_en => 'Spanish' }).count
      taxonomic
    end

    def self.geo_stats
      geo = {}
      geo[:geo_entity_types] = GeoEntityType.count
      geo[:geo_entities] = GeoEntity.count
      geo[:countries] = GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => { :name => GeoEntityType::COUNTRY }).count
      geo[:cites_regions] = GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => { :name => GeoEntityType::CITES_REGION }).count
      geo[:territories] = GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => { :name => GeoEntityType::TERRITORY }).count
      geo
    end

    def self.references_stats
      refs = {}
      refs[:references] = Reference.count
      refs[:taxon_references] = TaxonConceptReference.count
      refs[:taxon_standard_references] = TaxonConceptReference.where(:is_standard => true).count
      refs[:distribution_references] = DistributionReference.count
      refs
    end

    def self.trade_stats
      trade = {}
      trade[:terms] = Term.count
      trade[:sources] = Source.count
      trade[:units] = Unit.count
      trade[:purposes] = Purpose.count
      trade
    end

    def self.trade_restrictions_stats
      trade = {}
      trade[:quotas] = Quota.count
      trade[:cites_suspensions] = CitesSuspension.count
      trade[:eu_opinions] = EuOpinion.count
      trade[:eu_suspensions] = EuSuspension.count
      trade
    end

    def self.taxonomy_kingdom_stats(taxonomy, kingdom)
      stats = {}
      t = Taxonomy.find_by_name(taxonomy)
      k = TaxonConcept.find_by_full_name_and_taxonomy_id(kingdom, t.id)
      stats[:accepted_taxa] = TaxonConcept.where(
        :taxonomy_id => t.id,
        :name_status => 'A'
      ).where(["(data->'kingdom_id')::INT = ?", k.id]).count
      stats[:synonym_taxa] = TaxonConcept.where(
        :taxonomy_id => t.id, :name_status => 'S'
      ).where(["(data->'kingdom_id')::INT = ?", k.id]).count
      stats[:other_taxa] = TaxonConcept.where(
        :taxonomy_id => t.id
      ).where(["(data->'kingdom_id')::INT = ?", k.id]).
        where("name_status NOT IN ('A', 'S')").count
      stats[:listing_changes] = ListingChange.joins(:taxon_concept).
        where(:taxon_concepts => { :taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      distributions = Distribution.joins(:taxon_concept).
        where(:taxon_concepts => { :taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id])
      stats[:distributions] = distributions.count
      stats[:distribution_tags] = ActiveRecord::Base.connection.execute(<<-SQL
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
      stats[:distribution_references] = DistributionReference.
        joins(:distribution => :taxon_concept).
        where(:taxon_concepts => { :taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      stats[:taxon_references] = TaxonConceptReference.joins(:taxon_concept).
        where(:taxon_concepts => { :taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      stats[:taxon_standard_references] = TaxonConceptReference.joins(:taxon_concept).
        where(:taxon_concepts => { :taxonomy_id => t.id }, :taxon_concept_references => { :is_standard => true }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      stats[:common_names] =  TaxonCommon.joins(:taxon_concept).
        where(:taxon_concepts => { :taxonomy_id => t.id }).
        where(["(data->'kingdom_id')::INT = ?", k.id]).count
      stats
    end

    def self.database_summary
      puts "#############################################################"
      puts "#################                  ##########################"
      puts "################# Database Summary ##########################"
      puts "#################                  ##########################"
      puts "#############################################################\n"

      stats = self.database_stats
      print_count_for "Taxonomies", stats[:core][:taxonomies]
      print_count_for "Designations", stats[:core][:designations]
      print_count_for "Instruments", stats[:core][:instruments]
      print_count_for "Ranks", stats[:taxonomic][:ranks]
      print_count_for "TaxonName", stats[:taxonomic][:taxon_names]
      print_count_for "Total TaxonConcepts", stats[:taxonomic][:taxon_concepts]
      print_count_for "GeoEntityTypes", stats[:geo][:geo_entity_types]
      print_count_for "GeoEntities", stats[:geo][:geo_entities]
      print_count_for "Countries", stats[:geo][:countries]
      print_count_for "CITES Regions", stats[:geo][:cites_regions]
      print_count_for "Territories", stats[:geo][:territories]
      print_count_for "References", stats[:refs][:references]
      print_count_for "Taxon Concept References", stats[:refs][:taxon_references]
      print_count_for "Taxon Concept Standard References", stats[:refs][:taxon_standard_references]
      print_count_for "Distribution References", stats[:refs][:distribution_references]
      print_count_for "CommonNames", stats[:taxonomic][:common_names]
      print_count_for "English CommonNames", stats[:taxonomic][:common_names_en]
      print_count_for "French CommonNames", stats[:taxonomic][:common_names_fr]
      print_count_for "Spanish CommonNames", stats[:taxonomic][:common_names_es]
      puts ""
      print_count_for "Quotas", Quota.count
      print_count_for "CITES Suspensions", CitesSuspension.count
      print_count_for "EU Opinions", EuOpinion.count
      print_count_for "EU Suspensions", EuSuspension.count
      puts ""
      print_count_for "Terms", stats[:trade][:terms]
      print_count_for "Sources", stats[:trade][:sources]
      print_count_for "Units", stats[:trade][:units]
      print_count_for "Purpose", stats[:trade][:purposes]
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

      stats = self.taxonomy_kingdom_stats t.name, k.full_name

      print_count_for "Accepted", stats[:accepted_taxa]
      print_count_for "Synonyms", stats[:synonym_taxa]
      print_count_for "Neither accepted nor synonyms", stats[:other_taxa]
      print_count_for "Listing Changes", stats[:listing_changes]
      print_count_for "Distributions", stats[:distributions]
      print_count_for "Distribution Tags", stats[:distribution_tags]
      print_count_for "Distribution References", stats[:distribution_references]
      print_count_for "Taxon Concept References", stats[:taxon_references]
      print_count_for "Taxon Concept Standard References", stats[:taxon_standard_references]
      print_count_for "TaxonCommons", stats[:common_names]

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

    def self.print_count_for(klass, count)
      puts "#{count} #{klass}"
    end

  end
end
