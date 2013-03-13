# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts "#{ListingDistribution.delete_all} listing distributions deleted"
puts "#{GeoRelationship.delete_all} geo relationships deleted"
puts "#{GeoRelationshipType.delete_all} geo relationship types deleted"
GeoRelationshipType.dict.each do |type|
  GeoRelationshipType.create(name: type)
end
puts "#{GeoRelationshipType.count} geo relationship types created"

puts "#{DistributionReference.delete_all} taxon concept geo entity references deleted"
puts "#{Distribution.delete_all} taxon concept geo entities deleted"
ListingChange.update_all :annotation_id => nil
puts "#{Annotation.delete_all} annotations deleted"
puts "#{ListingChange.delete_all} listing changes deleted"
puts "#{GeoEntity.delete_all} geo entities deleted"
puts "#{GeoEntityType.delete_all} geo entity types deleted"
GeoEntityType.dict.each do |type|
  GeoEntityType.create(name: type)
end
puts "#{GeoEntityType.count} geo entity types created"

puts "#{TaxonRelationship.delete_all} taxon relationships deleted"
puts "#{TaxonRelationshipType.delete_all} taxon relationship types deleted"
['EQUAL_TO', 'INCLUDES', 'OVERLAPS', 'DISJUNCT'].each do |relationship|
  TaxonRelationshipType.create(:name => relationship, :is_intertaxonomic => true, :is_bidirectional => ['EQUAL_TO', 'DISJUNCT'].include?(relationship))
end
['HAS_SYNONYM', 'HAS_HYBRID'].each do |relationship|
  TaxonRelationshipType.create(:name => relationship, :is_intertaxonomic => false)
end
puts "#{TaxonRelationshipType.count} taxon relationship types created"

puts "#{TaxonCommon.delete_all} taxon commons deleted"
puts "#{TaxonConceptReference.delete_all} taxon_concept references deleted"
puts "#{TaxonConcept.delete_all} taxon_concepts deleted"
puts "#{TaxonName.delete_all} taxon_names deleted"
puts "#{Rank.delete_all} ranks deleted"

Rank.create(:name => Rank::KINGDOM, :taxonomic_position => '1', :fixed_order => true)
Rank.create(:name => Rank::PHYLUM, :taxonomic_position => '2', :fixed_order => true)
Rank.create(:name => Rank::CLASS, :taxonomic_position => '3', :fixed_order => true)
Rank.create(:name => Rank::ORDER, :taxonomic_position => '4', :fixed_order => false)
Rank.create(:name => Rank::FAMILY, :taxonomic_position => '5', :fixed_order => false)
Rank.create(:name => Rank::SUBFAMILY, :taxonomic_position => '5.1', :fixed_order => false)
Rank.create(:name => Rank::GENUS, :taxonomic_position => '6', :fixed_order => false)
Rank.create(:name => Rank::SPECIES, :taxonomic_position => '7', :fixed_order => false)
Rank.create(:name => Rank::SUBSPECIES, :taxonomic_position => '7.1', :fixed_order => false)
Rank.create(:name => Rank::VARIETY, :taxonomic_position => '7.2', :fixed_order => false)

puts "#{Rank.count} ranks created"

puts "#{SpeciesListing.delete_all} species listings deleted"
puts "#{ChangeType.delete_all} change types deleted"
puts "#{Designation.delete_all} designations deleted"
puts "#{Taxonomy.delete_all} taxonomies deleted"

Taxonomy.dict.each do |type|
  Taxonomy.create(name: type)
end
taxonomy = Taxonomy.find_by_name(Taxonomy::CITES_EU)
puts "#{Taxonomy.count} taxonomies created"

[Designation::CITES, Designation::EU].each do |designation|
  d = Designation.create(:name => designation, :taxonomy_id => taxonomy.id)
  ChangeType.dict.each do |change_type_name|
    ChangeType.create(:name => change_type_name, :designation_id => d.id)
  end
end

puts "#{Designation.count} designations created"
puts "#{ChangeType.count} change types created"

cites = Designation.find_by_name(Designation::CITES)

%w(I II III).each do |app_abbr|
  SpeciesListing.create(
    :name => "Appendix #{app_abbr}",
    :abbreviation => app_abbr,
    :designation_id => cites.id
  )
end

eu = Designation.find_by_name(Designation::EU)

%w(A B C D).each do |app_abbr|
  SpeciesListing.create(
    :name => "Annex #{app_abbr}",
    :abbreviation => app_abbr,
    :designation_id => eu.id
  )
end

puts "#{SpeciesListing.count} species listings created"

higher_taxa = [
  {
    :name => 'Animalia',
    :taxonomic_position => '1',
    :legacy_id => 1,
    :legacy_type => 'Animalia',
    :sub_taxa => [
      {
        :name => 'Annelida',
        :taxonomic_position => '1.4',
        :legacy_id => 1,
        :legacy_type => 'Animalia',
        :sub_taxa => [
          {
            :name => 'Hirudinoidea',
            :taxonomic_position => '1.4.1',
            :legacy_id => 14,
            :legacy_type => 'Animalia'
          }
        ]
      },
      {
        :name => 'Arthropoda',
        :taxonomic_position => '1.3',
        :legacy_id => 2,
        :legacy_type => 'Animalia',
        :sub_taxa => [
          {
            :name => 'Arachnida',
            :taxonomic_position => '1.3.1',
            :legacy_id => 4,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Insecta',
            :taxonomic_position => '1.3.2',
            :legacy_id => 16,
            :legacy_type => 'Animalia'
          }
        ]
      },
      {
        :name => 'Chordata',
        :taxonomic_position => '1.1',
        :legacy_id => 3,
        :legacy_type => 'Animalia',
        :sub_taxa => [
          {
            :name => 'Actinopterygii',
            :taxonomic_position => '1.1.6',
            :legacy_id => 1,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Amphibia',
            :taxonomic_position => '1.1.4',
            :legacy_id => 2,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Aves',
            :taxonomic_position => '1.1.2',
            :legacy_id => 5,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Elasmobranchii',
            :taxonomic_position => '1.1.5',
            :legacy_id => 11,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Mammalia',
            :taxonomic_position => '1.1.1',
            :legacy_id => 17,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Reptilia',
            :taxonomic_position => '1.1.3',
            :legacy_id => 23,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Sarcopterygii',
            :taxonomic_position => '1.1.7',
            :legacy_id => 24,
            :legacy_type => 'Animalia'
          }
        ]
      },
      {
        :name => 'Cnidaria',
        :taxonomic_position => '1.6',
        :legacy_id => 5,
        :legacy_type => 'Animalia',
        :sub_taxa => [
          {
            :name => 'Anthozoa',
            :taxonomic_position => '1.6.1',
            :legacy_id => 3,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Hydrozoa',
            :taxonomic_position => '1.6.2',
            :legacy_id => 15,
            :legacy_type => 'Animalia'
          }
        ]
      },
      {
        :name => 'Echinodermata',
        :taxonomic_position => '1.2',
        :legacy_id => 6,
        :legacy_type => 'Animalia',
        :sub_taxa => [
          {
            :name => 'Holothuroidea',
            :taxonomic_position => '1.2.1',
            :legacy_id => 41,
            :legacy_type => 'Animalia'
          }
        ]
      },
      {
        :name => 'Mollusca',
        :taxonomic_position => '1.5',
        :legacy_id => 7,
        :legacy_type => 'Animalia',
        :sub_taxa => [
          {
            :name => 'Bivalvia',
            :taxonomic_position => '1.5.1',
            :legacy_id => 6,
            :legacy_type => 'Animalia'
          },
          {
            :name => 'Gastropoda',
            :taxonomic_position => '1.5.2',
            :legacy_id => 13,
            :legacy_type => 'Animalia'
          }
        ]
      }
    ]
  },
  {
    :name => 'Plantae',
    :taxonomic_position => '2',
    :legacy_id => 2,
    :legacy_type => 'Plantae',
    :sub_taxa => []
  }
]

kingdom_rank_id = Rank.find_by_name(Rank::KINGDOM).id
higher_taxa.each do |kingdom_props|
  kingdom_name = kingdom_props[:name]
  name = TaxonName.create(:scientific_name => kingdom_name)
  kingdom = TaxonConcept.create(:rank_id => kingdom_rank_id,
    :taxon_name_id => name.id,
    :taxonomy_id => taxonomy.id,
    :legacy_id => kingdom_props[:legacy_id], :legacy_type => kingdom_props[:legacy_type],
    :taxonomic_position => kingdom_props[:taxonomic_position],
    :name_status => 'A')
  phyla = kingdom_props[:sub_taxa]
  phylum_rank_id = Rank.find_by_name(Rank::PHYLUM).id
  phyla.each do |phylum_props|
    phylum_name = phylum_props[:name]
    name = TaxonName.create(:scientific_name => phylum_name)
    phylum = TaxonConcept.create(:rank_id => phylum_rank_id,
      :taxon_name_id => name.id,
      :taxonomy_id => taxonomy.id,
      :legacy_id => phylum_props[:legacy_id], :legacy_type => phylum_props[:legacy_type],
      :parent_id => kingdom.id,
      :taxonomic_position => phylum_props[:taxonomic_position],
      :name_status => 'A')
    klasses = phylum_props[:sub_taxa]
    klass_rank_id = Rank.find_by_name(Rank::CLASS).id
    klasses.each do |klass_props|
      klass_name = klass_props[:name]
      name = TaxonName.create(
        :scientific_name => klass_name
      )
      klass = TaxonConcept.create(:rank_id => klass_rank_id,
      :taxon_name_id => name.id,
      :taxonomy_id => taxonomy.id,
      :legacy_id => klass_props[:legacy_id], :legacy_type => klass_props[:legacy_type],
      :parent_id => phylum.id,
      :taxonomic_position => klass_props[:taxonomic_position],
      :name_status => 'A')
    end
  end
end

puts "#{TaxonConcept.count} taxon_concepts created"
puts "#{TaxonName.count} taxon_names created"

puts "#{CommonName.delete_all} common names deleted"
puts "#{Language.delete_all} languages deleted"
Language.create(:name_en => 'English', :iso_code1 => 'en')
Language.create(:name_en => 'Spanish', :iso_code1 => 'es')
Language.create(:name_en => 'French', :iso_code1 => 'fr')
puts "#{Language.count} languages created"
puts "#{Reference.delete_all} references deleted"
