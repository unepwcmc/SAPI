# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts "#{ListingChange.delete_all} listing changes deleted"
puts "#{SpeciesListing.delete_all} species listings deleted"
puts "#{TaxonConceptGeoEntity.delete_all} taxon concept geo entities deleted"
puts "#{TaxonRelationship.delete_all} taxon relationships deleted"
puts "#{TaxonRelationshipType.delete_all} taxon relationship types deleted"
puts "#{TaxonConcept.delete_all} taxon_concepts deleted"
puts "#{TaxonName.delete_all} taxon_names deleted"
puts "#{Rank.delete_all} ranks deleted"
puts "#{Designation.delete_all} designations deleted"
puts "#{TaxonDistribution.delete_all} taxon distributions deleted"
puts "#{GeoRelationship.delete_all} geo relationships deleted"
puts "#{GeoEntity.delete_all} geo entities deleted"
puts "#{GeoEntityType.delete_all} geo entity types deleted"
puts "#{GeoRelationshipType.delete_all} geo relationship types deleted"

#Create GeoEntityTypes
GeoEntityType.dict.each do |type|
  entity_type = GeoEntityType.create(name: type)
  puts "Added GeoEntityType #{type}, with id: #{entity_type.id}"
end

#Create GeoRelationshipTypes
GeoRelationshipType.dict.each do |type|
  rel_type = GeoRelationshipType.create(name: type)
  puts "Added GeoRelationshipType #{type}, with id: #{rel_type.id}"
end

#Create rank seeds
parent_rank = nil
Rank.dict.each do |rank|
  rank = Rank.create(:name => rank, :parent_id => parent_rank)
  parent_rank = rank.id
  puts "Added rank #{rank.name}, with id #{rank.id}"
end

#Create designation seeds
[Designation::CITES, 'CMS'].each do |designation|
  Designation.create(:name => designation)
end
cites = Designation.find_by_name(Designation::CITES)
cms = Designation.find_by_name('CMS')

#Create taxon seeds

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
            :taxonomic_position => '1.4.1',
            :abbreviation => 'Hi'
          }
        ]
      },
      {
        :name => 'Arthropoda',
        :taxonomic_position => '1.3',
        :sub_taxa => [
          {
            :name => 'Arachnida',
            :taxonomic_position => '1.3.1',
            :abbreviation => 'Ar'
          },
          {
            :name => 'Insecta',
            :taxonomic_position => '1.3.2',
            :abbreviation => 'In'
          }
        ]
      },
      {
        :name => 'Chordata',
        :taxonomic_position => '1.1',
        :sub_taxa => [
          {
            :name => 'Actinopterygii',
            :taxonomic_position => '1.1.6',
            :abbreviation => 'Ac'
          },
          {
            :name => 'Amphibia',
            :taxonomic_position => '1.1.4',
            :abbreviation => 'Am'
          },
          {
            :name => 'Aves',
            :taxonomic_position => '1.1.2',
            :abbreviation => 'Av'
          },
          {
            :name => 'Elasmobranchii',
            :taxonomic_position => '1.1.5',
            :abbreviation => 'El'
          },
          {
            :name => 'Mammalia',
            :taxonomic_position => '1.1.1',
            :abbreviation => 'MA'
          },
          {
            :name => 'Reptilia',
            :taxonomic_position => '1.1.3',
            :abbreviation => 'Re'
          },
          {
            :name => 'Sarcopterygii',
            :taxonomic_position => '1.1.7',
            :abbreviation => 'Sa'
          }
        ]
      },
      {
        :name => 'Cnidaria',
        :taxonomic_position => '1.6',
        :sub_taxa => [
          {
            :name => 'Anthozoa',
            :taxonomic_position => '1.6.1',
            :abbreviation => 'An'
          },
          {
            :name => 'Hydrozoa',
            :taxonomic_position => '1.6.2',
            :abbreviation => 'Hy'
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
            :taxonomic_position => '1.5.1',
            :abbreviation => 'Bi'
          },
          {
            :name => 'Gastropoda',
            :taxonomic_position => '1.5.2',
            :abbreviation => 'Ga'
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
      klass_abbr = klass_props[:abbreviation]
      name = TaxonName.create(
        :scientific_name => klass_name,
        :abbreviation => klass_abbr
      )
      klass = TaxonConcept.create(:rank_id => klass_rank_id,
      :taxon_name_id => name.id, :designation_id => cites.id,
      :parent_id => phylum.id,
      :data => {'taxonomic_position' => klass_props[:taxonomic_position]})
    end
  end
end

#phyla

klass = TaxonConcept.joins(:taxon_name).
  where(:"taxon_names.scientific_name" => 'Mammalia').first
#honey badger
name = TaxonName.create(:scientific_name => 'Carnivora')
order = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::ORDER).id,
  :taxon_name_id => name.id, :parent_id => klass.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Mustelidae')
family = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::FAMILY).id,
  :taxon_name_id => name.id, :parent_id => order.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Mellivora')
genus = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::GENUS).id,
  :taxon_name_id => name.id, :parent_id => family.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Capensis')
species = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::SPECIES).id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cites.id)

#loxodonta
name = TaxonName.create(:scientific_name => 'Proboscidea')
order = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::ORDER).id,
  :taxon_name_id => name.id, :parent_id => klass.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Elephantidae')
family = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::FAMILY).id,
  :taxon_name_id => name.id, :parent_id => order.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Loxodonta')
genus = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::GENUS).id,
  :taxon_name_id => name.id, :parent_id => family.id,
  :designation_id => cites.id)
#loxodonta africana CITES
name = TaxonName.create(:scientific_name => 'Africana')
loxodonta_cites = TaxonConcept.create(
  :rank_id => Rank.find_by_name(Rank::SPECIES).id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cites.id)

#listing changes for loxodonta africana
ChangeType.dict.each { |name| ChangeType.create(:name => name) }
appendix_II = SpeciesListing.create(:name => 'Appendix II', :abbreviation => 'II',
  :designation_id => cites.id)
ListingChange.create(
  :taxon_concept_id => loxodonta_cites.id,
  :species_listing_id => appendix_II.id,
  :effective_at => '1977-02-04',
  :change_type_id => ChangeType.find_by_name('ADDITION').id)
ListingChange.create(
  :taxon_concept_id => loxodonta_cites.id,
  :species_listing_id => appendix_II.id,
  :effective_at => '1990-01-18',
  :change_type_id => ChangeType.find_by_name('DELETION').id)
appendix_I = SpeciesListing.create(:name => 'Appendix I', :abbreviation => 'I',
  :designation_id => cites.id)
ListingChange.create(
  :taxon_concept_id => loxodonta_cites.id,
  :species_listing_id => appendix_I.id,
  :effective_at => '1990-01-18',
  :change_type_id => ChangeType.find_by_name('ADDITION').id)
app_II_change = ListingChange.create(
  :taxon_concept_id => loxodonta_cites.id,
  :species_listing_id => appendix_II.id,
  :effective_at => '1997-09-18',
  :change_type_id => ChangeType.find_by_name('ADDITION').id)

#loxodonta africana CMS
name = TaxonName.create(:scientific_name => 'Africana')
loxodonta_cms1 = TaxonConcept.create(
  :rank_id => Rank.find_by_name(Rank::SPECIES).id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cms.id
)
name = TaxonName.create(:scientific_name => 'Cyclotis')
loxodonta_cms2 = TaxonConcept.create(
  :rank_id => Rank.find_by_name(Rank::SPECIES).id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cms.id)

#Create taxon relationship type seeds
TaxonRelationshipType.dict.each do |relationship|
  TaxonRelationshipType.create(:name => relationship)
end

#Create loxodonta relationship seeds
TaxonRelationship.create(
  :taxon_concept_id => loxodonta_cites.id, :other_taxon_concept_id => loxodonta_cms1.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name(TaxonRelationshipType::CONTAINS).id
)
TaxonRelationship.create(
  :taxon_concept_id => loxodonta_cites.id, :other_taxon_concept_id => loxodonta_cms2.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name(TaxonRelationshipType::CONTAINS).id
)

kingdom = TaxonConcept.joins(:taxon_name).
  where(:"taxon_names.scientific_name" => 'Plantae').first
name = TaxonName.create(:scientific_name => 'Violales')
order = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::ORDER).id,
  :taxon_name_id => name.id, :parent_id => kingdom.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Violaceae')
family = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::FAMILY).id,
  :taxon_name_id => name.id, :parent_id => order.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Viola')
genus = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::GENUS).id,
  :taxon_name_id => name.id, :parent_id => family.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Montana L.')
viola_montana = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::SPECIES).id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Canina L.')
viola_canina = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::SPECIES).id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Montana (L.) Hartman')
viola_canina_ssp = TaxonConcept.create(:rank_id => Rank.find_by_name(Rank::SUBSPECIES).id,
  :taxon_name_id => name.id, :parent_id => viola_canina.id,
  :designation_id => cites.id)

TaxonRelationship.create(
  :taxon_concept_id => viola_montana.id, :other_taxon_concept_id => viola_canina_ssp.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name(TaxonRelationshipType::SYNONYM).id
)
TaxonRelationship.create(
  :taxon_concept_id => viola_canina_ssp.id, :other_taxon_concept_id => viola_montana.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name(TaxonRelationshipType::SYNONYM).id
)
