# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Rails.logger.debug { "#{ListingDistribution.delete_all} listing distributions deleted" }
Rails.logger.debug { "#{GeoRelationship.delete_all} geo relationships deleted" }
Rails.logger.debug { "#{GeoRelationshipType.delete_all} geo relationship types deleted" }
GeoRelationshipType.dict.each do |type|
  GeoRelationshipType.create!(name: type)
end
Rails.logger.debug { "#{GeoRelationshipType.count} geo relationship types created" }

Rails.logger.debug { "#{DistributionReference.delete_all} taxon concept geo entity references deleted" }
Rails.logger.debug { "#{Distribution.delete_all} taxon concept geo entities deleted" }
ListingChange.update_all annotation_id: nil
Rails.logger.debug { "#{Annotation.delete_all} annotations deleted" }
Rails.logger.debug { "#{ListingChange.delete_all} listing changes deleted" }
Rails.logger.debug { "#{GeoEntity.delete_all} geo entities deleted" }
Rails.logger.debug { "#{GeoEntityType.delete_all} geo entity types deleted" }
GeoEntityType.dict.each do |type|
  GeoEntityType.create!(name: type)
end
Rails.logger.debug { "#{GeoEntityType.count} geo entity types created" }

Rails.logger.debug { "#{TaxonRelationship.delete_all} taxon relationships deleted" }
Rails.logger.debug { "#{TaxonRelationshipType.delete_all} taxon relationship types deleted" }
[ 'EQUAL_TO', 'INCLUDES', 'OVERLAPS', 'DISJUNCT' ].each do |relationship|
  TaxonRelationshipType.create!(name: relationship, is_intertaxonomic: true, is_bidirectional: [ 'EQUAL_TO', 'DISJUNCT' ].include?(relationship))
end
[ 'HAS_SYNONYM', 'HAS_HYBRID', 'HAS_TRADE_NAME' ].each do |relationship|
  TaxonRelationshipType.create!(name: relationship, is_intertaxonomic: false)
end
Rails.logger.debug { "#{TaxonRelationshipType.count} taxon relationship types created" }

Rails.logger.debug { "#{TaxonCommon.delete_all} taxon commons deleted" }
Rails.logger.debug { "#{TaxonConceptReference.delete_all} taxon_concept references deleted" }
Rails.logger.debug { "#{TaxonConcept.delete_all} taxon_concepts deleted" }
Rails.logger.debug { "#{TaxonName.delete_all} taxon_names deleted" }
Rails.logger.debug { "#{Rank.delete_all} ranks deleted" }

Rails.logger.debug { "#{Quota.delete_all} quotas deleted" }
Rails.logger.debug { "#{TradeRestrictionTerm.delete_all} trade restrictions terms deleted" }
Rails.logger.debug { "#{TradeRestrictionSource.delete_all} trade restrictions sources deleted" }
Rails.logger.debug { "#{TradeRestrictionPurpose.delete_all} trade restrictions purposes deleted" }

Rank.create!(name: Rank::KINGDOM, display_name_en: Rank::KINGDOM, taxonomic_position: '1', fixed_order: true)
Rank.create!(name: Rank::PHYLUM, display_name_en: Rank::PHYLUM, taxonomic_position: '2', fixed_order: true)
Rank.create!(name: Rank::CLASS, display_name_en: Rank::CLASS, taxonomic_position: '3', fixed_order: true)
Rank.create!(name: Rank::ORDER, display_name_en: Rank::ORDER, taxonomic_position: '4', fixed_order: false)
Rank.create!(name: Rank::FAMILY, display_name_en: Rank::FAMILY, taxonomic_position: '5', fixed_order: false)
Rank.create!(name: Rank::SUBFAMILY, display_name_en: Rank::SUBFAMILY, taxonomic_position: '5.1', fixed_order: false)
Rank.create!(name: Rank::GENUS, display_name_en: Rank::GENUS, taxonomic_position: '6', fixed_order: false)
Rank.create!(name: Rank::SPECIES, display_name_en: Rank::SPECIES, taxonomic_position: '7', fixed_order: false)
Rank.create!(name: Rank::SUBSPECIES, display_name_en: Rank::SUBSPECIES, taxonomic_position: '7.1', fixed_order: false)
Rank.create!(name: Rank::VARIETY, display_name_en: Rank::VARIETY, taxonomic_position: '7.2', fixed_order: false)

Rails.logger.debug { "#{Rank.count} ranks created" }

Rails.logger.debug { "#{SpeciesListing.delete_all} species listings deleted" }
Rails.logger.debug { "#{ChangeType.delete_all} change types deleted" }
Rails.logger.debug { "#{Event.delete_all} events deleted" }
Rails.logger.debug { "#{Designation.delete_all} designations deleted" }
Rails.logger.debug { "#{Taxonomy.delete_all} taxonomies deleted" }

Rails.logger.debug { "#{DocumentTag.delete_all} document tags deleted" }

[
  'I', 'II', 'III', 'IV', 'June 1986', 'None',
  'Post-CoP11', 'Post-CoP12', 'Post-CoP13'
].each { |tag| DocumentTag::ReviewPhase.create!(name: tag) }

[
  'AC review and categorization (k)', 'AC review and categorization [k]',
  'AC review (e)', 'AC review [e]', 'Categorise information (i)', 'Consulation (d)',
  'PC review and categorization [k]', 'PC review and categorization (m)', 'PC review (e)',
  'Research of species [j]', 'Selection of species (b)', 'Selection of species [b]',
  'Species selection (b)', 'Species selection [b]'
].each { |tag| DocumentTag::ProcessStage.create!(name: tag) }

[
  'Accepted', 'Cancelled', 'Deferred',
  'Redundant', 'Rejected', 'Transferred to other proposals',
  'Withdrawn', 'Accepted as amended', 'Rejected as amended',
  'Accepted with implementation delay',
  'Accepted as amended with implementation delay',
  'Adopted'
].each { |tag| DocumentTag::ProposalOutcome.create!(name: tag) }

Rails.logger.debug { "#{DocumentTag.count} document tags created" }

Taxonomy.dict.each do |type|
  Taxonomy.create!(name: type)
end
taxonomy = Taxonomy.find_by(name: Taxonomy::CITES_EU)
cms_taxonomy = Taxonomy.find_by(name: Taxonomy::CMS)
Rails.logger.debug { "#{Taxonomy.count} taxonomies created" }

[ Designation::CITES, Designation::EU ].each do |designation|
  d = Designation.create!(name: designation, taxonomy_id: taxonomy.id)

  ChangeType.dict.each do |change_type_name|
    ChangeType.create!(name: change_type_name, display_name_en: change_type_name, designation_id: d.id)
  end
end

[ Designation::CMS ].each do |designation|
  d = Designation.create!(name: designation, taxonomy_id: cms_taxonomy.id)
end

Rails.logger.debug { "#{Designation.count} designations created" }
Rails.logger.debug { "#{ChangeType.count} change types created" }

cites = Designation.find_by(name: Designation::CITES)

%w[I II III].each do |app_abbr|
  SpeciesListing.create!(
    name: "Appendix #{app_abbr}",
    abbreviation: app_abbr,
    designation_id: cites.id
  )
end

eu = Designation.find_by(name: Designation::EU)

%w[A B C D].each do |app_abbr|
  SpeciesListing.create!(
    name: "Annex #{app_abbr}",
    abbreviation: app_abbr,
    designation_id: eu.id
  )
end

cms = Designation.find_by(name: Designation::CMS)

%w[I II].each do |app_abbr|
  SpeciesListing.create!(
    name: "Appendix #{app_abbr}",
    abbreviation: app_abbr,
    designation_id: cms.id
  )
end

Rails.logger.debug { "#{SpeciesListing.count} species listings created" }

higher_taxa = [
  {
    name: 'Animalia',
    taxonomic_position: '1',
    legacy_id: 1,
    legacy_type: 'Animalia',
    sub_taxa: [
      {
        name: 'Annelida',
        taxonomic_position: '1.4',
        legacy_id: 1,
        legacy_type: 'Animalia',
        sub_taxa: [
          {
            name: 'Hirudinoidea',
            taxonomic_position: '1.4.1',
            legacy_id: 14,
            legacy_type: 'Animalia'
          }
        ]
      },
      {
        name: 'Arthropoda',
        taxonomic_position: '1.3',
        legacy_id: 2,
        legacy_type: 'Animalia',
        sub_taxa: [
          {
            name: 'Arachnida',
            taxonomic_position: '1.3.1',
            legacy_id: 4,
            legacy_type: 'Animalia'
          },
          {
            name: 'Insecta',
            taxonomic_position: '1.3.2',
            legacy_id: 16,
            legacy_type: 'Animalia'
          }
        ]
      },
      {
        name: 'Chordata',
        taxonomic_position: '1.1',
        legacy_id: 3,
        legacy_type: 'Animalia',
        sub_taxa: [
          {
            name: 'Actinopterygii',
            taxonomic_position: '1.1.6',
            legacy_id: 1,
            legacy_type: 'Animalia'
          },
          {
            name: 'Amphibia',
            taxonomic_position: '1.1.4',
            legacy_id: 2,
            legacy_type: 'Animalia'
          },
          {
            name: 'Aves',
            taxonomic_position: '1.1.2',
            legacy_id: 5,
            legacy_type: 'Animalia'
          },
          {
            name: 'Elasmobranchii',
            taxonomic_position: '1.1.5',
            legacy_id: 11,
            legacy_type: 'Animalia'
          },
          {
            name: 'Mammalia',
            taxonomic_position: '1.1.1',
            legacy_id: 17,
            legacy_type: 'Animalia'
          },
          {
            name: 'Reptilia',
            taxonomic_position: '1.1.3',
            legacy_id: 23,
            legacy_type: 'Animalia'
          },
          {
            name: 'Sarcopterygii',
            taxonomic_position: '1.1.7',
            legacy_id: 24,
            legacy_type: 'Animalia'
          },
          {
            name: 'Cephalaspidomorphi',
            taxonomic_position: '1.1.8',
            legacy_id: 7,
            legacy_type: 'Animalia'
          }
        ]
      },
      {
        name: 'Cnidaria',
        taxonomic_position: '1.6',
        legacy_id: 5,
        legacy_type: 'Animalia',
        sub_taxa: [
          {
            name: 'Anthozoa',
            taxonomic_position: '1.6.1',
            legacy_id: 3,
            legacy_type: 'Animalia'
          },
          {
            name: 'Hydrozoa',
            taxonomic_position: '1.6.2',
            legacy_id: 15,
            legacy_type: 'Animalia'
          }
        ]
      },
      {
        name: 'Echinodermata',
        taxonomic_position: '1.2',
        legacy_id: 6,
        legacy_type: 'Animalia',
        sub_taxa: [
          {
            name: 'Holothuroidea',
            taxonomic_position: '1.2.1',
            legacy_id: 41,
            legacy_type: 'Animalia'
          },
          {
            name: 'Stelleroidea',
            taxonomic_position: '1.2.2',
            legacy_id: 26,
            legacy_type: 'Animalia'
          }
        ]
      },
      {
        name: 'Mollusca',
        taxonomic_position: '1.5',
        legacy_id: 7,
        legacy_type: 'Animalia',
        sub_taxa: [
          {
            name: 'Bivalvia',
            taxonomic_position: '1.5.1',
            legacy_id: 6,
            legacy_type: 'Animalia'
          },
          {
            name: 'Gastropoda',
            taxonomic_position: '1.5.2',
            legacy_id: 13,
            legacy_type: 'Animalia'
          }
        ]
      }
    ]
  },
  {
    name: 'Plantae',
    taxonomic_position: '2',
    legacy_id: 2,
    legacy_type: 'Plantae',
    sub_taxa: []
  }
]

kingdom_rank_id = Rank.find_by(name: Rank::KINGDOM).id
higher_taxa.each do |kingdom_props|
  kingdom_name = kingdom_props[:name]
  [ cms_taxonomy, taxonomy ].each do |taksonomy|
    name = TaxonName.find_or_create_by(scientific_name: kingdom_name)
    next if taksonomy.name == Taxonomy::CMS && kingdom_name == 'Plantae'
    kingdom = TaxonConcept.create!(rank_id: kingdom_rank_id,
      taxon_name_id: name.id,
      taxonomy_id: taksonomy.id,
      legacy_id: kingdom_props[:legacy_id], legacy_type: kingdom_props[:legacy_type],
      taxonomic_position: kingdom_props[:taxonomic_position],
      name_status: 'A')
    phyla = kingdom_props[:sub_taxa]
    phylum_rank_id = Rank.find_by(name: Rank::PHYLUM).id
    phyla.each do |phylum_props|
      phylum_name = phylum_props[:name]
      name = TaxonName.find_or_create_by(scientific_name: phylum_name)
      phylum = TaxonConcept.create!(rank_id: phylum_rank_id,
        taxon_name_id: name.id,
        taxonomy_id: taksonomy.id,
        legacy_id: phylum_props[:legacy_id], legacy_type: phylum_props[:legacy_type],
        parent_id: kingdom.id,
        taxonomic_position: phylum_props[:taxonomic_position],
        name_status: 'A')
      klasses = phylum_props[:sub_taxa]
      klass_rank_id = Rank.find_by(name: Rank::CLASS).id
      klasses.each do |klass_props|
        klass_name = klass_props[:name]
        name = TaxonName.find_or_create_by(scientific_name: klass_name)
        klass = TaxonConcept.create!(rank_id: klass_rank_id,
          taxon_name_id: name.id,
          taxonomy_id: taksonomy.id,
          legacy_id: klass_props[:legacy_id], legacy_type: klass_props[:legacy_type],
          parent_id: phylum.id,
          taxonomic_position: klass_props[:taxonomic_position],
          name_status: 'A')
      end
    end
  end
end

Rails.logger.debug { "#{TaxonConcept.count} taxon_concepts created" }
Rails.logger.debug { "#{TaxonName.count} taxon_names created" }

Rails.logger.debug { "#{CommonName.delete_all} common names deleted" }
Rails.logger.debug { "#{Language.delete_all} languages deleted" }
Rails.logger.debug { "#{Reference.delete_all} references deleted" }
Rails.logger.debug { "#{TradeRestriction.delete_all} trade restrictions deleted" }

[ 'trading_partner', 'term_code', 'taxon_name', 'appendix', 'quantity', 'year' ].each do |col|
  Trade::PresenceValidationRule.create!(column_names: [ col ], run_order: 1)
end
[ 'quantity', 'year' ].each do |col|
  Trade::NumericalityValidationRule.create!(
    column_names: [ col ],
    run_order: 2,
    is_strict: true
  )
end

Trade::FormatValidationRule.create!(
  column_names: [ 'year' ],
  format_re: '^\d{4}$',
  run_order: 2,
  is_strict: true
)

Trade::InclusionValidationRule.create!(
  column_names: [ 'term_code' ],
  valid_values_view: 'valid_term_code_view',
  run_order: 3,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'source_code' ],
  valid_values_view: 'valid_source_code_view',
  run_order: 3,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'purpose_code' ],
  valid_values_view: 'valid_purpose_code_view',
  run_order: 3,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'unit_code' ],
  valid_values_view: 'valid_unit_code_view',
  run_order: 3,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'trading_partner' ],
  valid_values_view: 'valid_trading_partner_view',
  run_order: 3,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'country_of_origin' ],
  valid_values_view: 'valid_country_of_origin_view',
  run_order: 3,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'taxon_name' ],
  valid_values_view: 'valid_taxon_name_view',
  run_order: 3,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'appendix' ],
  valid_values_view: 'valid_appendix_view',
  run_order: 3,
  is_strict: true
)
Trade::TaxonConceptAppendixYearValidationRule.create!(
  column_names: [ 'taxon_concept_id', 'appendix', 'year' ],
  valid_values_view: 'valid_taxon_concept_appendix_year_mview',
  run_order: 4,
  is_primary: false,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'term_code', 'unit_code' ],
  valid_values_view: 'valid_term_unit_view',
  run_order: 4,
  is_primary: false
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'term_code', 'purpose_code' ],
  valid_values_view: 'valid_term_purpose_view',
  run_order: 4,
  is_primary: false
)
Trade::InclusionValidationRule.create!(
  column_names: [ 'taxon_concept_id', 'term_code' ],
  valid_values_view: 'valid_taxon_concept_term_view',
  run_order: 4,
  is_primary: false,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  scope: {
    rank: { inclusion: [ Rank::SPECIES, Rank::SUBSPECIES ] },
    source_code: { inclusion: [ 'W' ] },
    country_of_origin: { exclusion: [ 'XX' ] }
  },
  column_names: [ 'taxon_concept_id', 'country_of_origin' ],
  valid_values_view: 'valid_taxon_concept_country_of_origin_view',
  run_order: 4,
  is_primary: false,
  is_strict: true
)
Trade::InclusionValidationRule.create!(
  scope: {
    rank: { inclusion: [ Rank::SPECIES, Rank::SUBSPECIES ] },
    source_code: { inclusion: [ 'W' ] },
    country_of_origin: { blank: true },
    exporter: { exclusion: [ 'XX' ] }
  },
  column_names: [ 'taxon_concept_id', 'exporter' ],
  valid_values_view: 'valid_taxon_concept_exporter_view',
  run_order: 4,
  is_primary: false,
  is_strict: true
)
Trade::DistinctValuesValidationRule.create!(
  column_names: [ 'exporter', 'country_of_origin' ],
  run_order: 4,
  is_primary: false,
  is_strict: true
)
Trade::DistinctValuesValidationRule.create!(
  column_names: [ 'exporter', 'importer' ],
  run_order: 4,
  is_primary: false,
  is_strict: true
)

Trade::TaxonConceptSourceValidationRule.create!(
  column_names: [ 'taxon_concept_id', 'source_code' ],
  run_order: 4,
  is_primary: false,
  is_strict: true
)
