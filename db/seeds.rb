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

puts "#{TaxonConceptGeoEntity.delete_all} taxon concept geo entities deleted"
puts "#{ListingChange.delete_all} listing changes deleted"
puts "#{GeoEntity.delete_all} geo entities deleted"
puts "#{GeoEntityType.delete_all} geo entity types deleted"
GeoEntityType.dict.each do |type|
  GeoEntityType.create(name: type)
end
puts "#{GeoEntityType.count} geo entity types created"

puts "#{ChangeType.delete_all} change types deleted"
ChangeType.dict.each { |change_type_name| ChangeType.create(:name => change_type_name) }
puts "#{ChangeType.count} change types created"

puts "#{TaxonRelationship.delete_all} taxon relationships deleted"
puts "#{TaxonRelationshipType.delete_all} taxon relationship types deleted"
TaxonRelationshipType.dict.each do |relationship|
  TaxonRelationshipType.create(:name => relationship)
end
puts "#{TaxonRelationshipType.count} taxon relationship types created"

puts "#{TaxonConcept.delete_all} taxon_concepts deleted"
puts "#{TaxonName.delete_all} taxon_names deleted"
puts "#{Rank.delete_all} ranks deleted"

parent_rank = nil
Rank.dict.each do |rank|
  rank = Rank.create(:name => rank, :parent_id => parent_rank)
  parent_rank = rank.id
end
puts "#{Rank.count} ranks created"

puts "#{SpeciesListing.delete_all} species listings deleted"
puts "#{Designation.delete_all} designations deleted"
[Designation::CITES, 'CMS'].each do |designation|
  Designation.create(:name => designation)
end
cites = Designation.find_by_name(Designation::CITES)
cms = Designation.find_by_name('CMS')
puts "#{Designation.count} designations created"
%w(I II III).each do |app_abbr|
  SpeciesListing.create(
    :name => "Appendix #{app_abbr}",
    :abbreviation => app_abbr,
    :designation_id => cites.id
  )
end
puts "#{SpeciesListing.count} species listings created"

higher_taxa = [
  {
    :name => 'Animalia',
    :taxonomic_position => '1',
    :sub_taxa => [
      {
        :name => 'Annelida',
        :taxonomic_position => '1.4',
        :sub_taxa => [
          {
            :name => 'Hirudinoidea',
            :taxonomic_position => '1.4.1'
          }
        ]
      },
      {
        :name => 'Arthropoda',
        :taxonomic_position => '1.3',
        :sub_taxa => [
          {
            :name => 'Arachnida',
            :taxonomic_position => '1.3.1'
          },
          {
            :name => 'Insecta',
            :taxonomic_position => '1.3.2'
          }
        ]
      },
      {
        :name => 'Chordata',
        :taxonomic_position => '1.1',
        :sub_taxa => [
          {
            :name => 'Actinopterygii',
            :taxonomic_position => '1.1.6'
          },
          {
            :name => 'Amphibia',
            :taxonomic_position => '1.1.4'
          },
          {
            :name => 'Aves',
            :taxonomic_position => '1.1.2'
          },
          {
            :name => 'Elasmobranchii',
            :taxonomic_position => '1.1.5'
          },
          {
            :name => 'Mammalia',
            :taxonomic_position => '1.1.1'
          },
          {
            :name => 'Reptilia',
            :taxonomic_position => '1.1.3'
          },
          {
            :name => 'Sarcopterygii',
            :taxonomic_position => '1.1.7'
          }
        ]
      },
      {
        :name => 'Cnidaria',
        :taxonomic_position => '1.6',
        :sub_taxa => [
          {
            :name => 'Anthozoa',
            :taxonomic_position => '1.6.1'
          },
          {
            :name => 'Hydrozoa',
            :taxonomic_position => '1.6.2'
          }
        ]
      },
      {
        :name => 'Echinodermata',
        :taxonomic_position => '1.2',
        :sub_taxa => [
          {
            :name => 'Holothuroidea',
            :taxonomic_position => '1.2.1'
          }
        ]
      },
      {
        :name => 'Mollusca',
        :taxonomic_position => '1.5',
        :sub_taxa => [
          {
            :name => 'Bivalvia',
            :taxonomic_position => '1.5.1'
          },
          {
            :name => 'Gastropoda',
            :taxonomic_position => '1.5.2'
          }
        ]
      }
    ]
  },
  {
    :name => 'Plantae',
    :taxonomic_position => '2',
    :sub_taxa => []
  }
]

kingdom_rank_id = Rank.find_by_name(Rank::KINGDOM).id
higher_taxa.each do |kingdom_props|
  kingdom_name = kingdom_props[:name]
  name = TaxonName.create(:scientific_name => kingdom_name)
  kingdom = TaxonConcept.create(:rank_id => kingdom_rank_id,
    :taxon_name_id => name.id, :designation_id => cites.id,
    :data => {'taxonomic_position' => kingdom_props[:taxonomic_position]})
  phyla = kingdom_props[:sub_taxa]
  phylum_rank_id = Rank.find_by_name(Rank::PHYLUM).id
  phyla.each do |phylum_props|
    phylum_name = phylum_props[:name]
    name = TaxonName.create(:scientific_name => phylum_name)
    phylum = TaxonConcept.create(:rank_id => phylum_rank_id,
      :taxon_name_id => name.id, :designation_id => cites.id,
      :parent_id => kingdom.id,
      :data => {'taxonomic_position' => phylum_props[:taxonomic_position]})
    klasses = phylum_props[:sub_taxa]
    klass_rank_id = Rank.find_by_name(Rank::CLASS).id
    klasses.each do |klass_props|
      klass_name = klass_props[:name]
      name = TaxonName.create(
        :scientific_name => klass_name
      )
      klass = TaxonConcept.create(:rank_id => klass_rank_id,
      :taxon_name_id => name.id, :designation_id => cites.id,
      :parent_id => phylum.id,
      :data => {'taxonomic_position' => klass_props[:taxonomic_position]})
    end
  end
end

puts "#{TaxonConcept.count} taxon_concepts created"
puts "#{TaxonName.count} taxon_names created"
