# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts "#{TaxonRelationship.delete_all} taxon relationships deleted"
puts "#{TaxonRelationshipType.delete_all} taxon relationship types deleted"
puts "#{TaxonConcept.delete_all} taxon_concepts deleted"
puts "#{TaxonName.delete_all} taxon_names deleted"
puts "#{Rank.delete_all} ranks deleted"
puts "#{Designation.delete_all} designations deleted"

#Create rank seeds
parent_rank = nil
['Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species', 'Subspecies'].each do |rank|
  rank = Rank.create(:name => rank, :parent_id => parent_rank)
  parent_rank = rank.id
  puts "Added rank #{rank.name}, with id #{rank.id}"
end

#Create designation seeds
['CITES', 'CMS'].each do |designation|
  Designation.create(:name => designation)
end
cites = Designation.find_by_name('CITES')
cms = Designation.find_by_name('CMS')
#Create taxon seeds
name = TaxonName.create(:scientific_name => 'Animalia')
kingdom = TaxonConcept.create(:rank_id => Rank.find_by_name('Kingdom').id,
  :taxon_name_id => name.id, :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Chordata')
phylum = TaxonConcept.create(:rank_id => Rank.find_by_name('Phylum').id,
  :taxon_name_id => name.id, :parent_id => kingdom.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Mammalia')
klass = TaxonConcept.create(:rank_id => Rank.find_by_name('Class').id,
  :taxon_name_id => name.id, :parent_id => phylum.id,
  :designation_id => cites.id)

#honey badger
name = TaxonName.create(:scientific_name => 'Carnivora')
order = TaxonConcept.create(:rank_id => Rank.find_by_name('Order').id,
  :taxon_name_id => name.id, :parent_id => klass.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Mustelidae')
family = TaxonConcept.create(:rank_id => Rank.find_by_name('Family').id,
  :taxon_name_id => name.id, :parent_id => order.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Mellivora')
genus = TaxonConcept.create(:rank_id => Rank.find_by_name('Genus').id,
  :taxon_name_id => name.id, :parent_id => family.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Mellivora capensis')
species = TaxonConcept.create(:rank_id => Rank.find_by_name('Species').id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cites.id)

#loxodonta
name = TaxonName.create(:scientific_name => 'Proboscidea')
order = TaxonConcept.create(:rank_id => Rank.find_by_name('Order').id,
  :taxon_name_id => name.id, :parent_id => klass.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Elephantidae')
family = TaxonConcept.create(:rank_id => Rank.find_by_name('Family').id,
  :taxon_name_id => name.id, :parent_id => order.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Loxodonta')
genus = TaxonConcept.create(:rank_id => Rank.find_by_name('Genus').id,
  :taxon_name_id => name.id, :parent_id => family.id,
  :designation_id => cites.id)
#loxodonta africana CITES
name = TaxonName.create(:scientific_name => 'Loxodonta africana')
loxodonta_cites = TaxonConcept.create(
  :rank_id => Rank.find_by_name('Species').id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cites.id)
#loxodonta africana CMS
name = TaxonName.create(:scientific_name => 'Loxodonta africana')
loxodonta_cms1 = TaxonConcept.create(
  :rank_id => Rank.find_by_name('Species').id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cms.id
)
name = TaxonName.create(:scientific_name => 'Loxodonta cyclotis')
loxodonta_cms2 = TaxonConcept.create(
  :rank_id => Rank.find_by_name('Species').id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cms.id)

#Create taxon relationship type seeds
['has_part', 'is_part_of', 'is_synonym'].each do |relationship|
  TaxonRelationshipType.create(:name => relationship)
end

#Create loxodonta relationship seeds
TaxonRelationship.create(
  :taxon_concept_id => loxodonta_cites.id, :other_taxon_concept_id => loxodonta_cms1.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name('has_part').id
)
TaxonRelationship.create(
  :taxon_concept_id => loxodonta_cites.id, :other_taxon_concept_id => loxodonta_cms2.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name('has_part').id
)
TaxonRelationship.create(
  :taxon_concept_id => loxodonta_cms1.id, :other_taxon_concept_id => loxodonta_cites.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name('is_part_of').id
)
TaxonRelationship.create(
  :taxon_concept_id => loxodonta_cms2.id, :other_taxon_concept_id => loxodonta_cites.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name('is_part_of').id
)

name = TaxonName.create(:scientific_name => 'Plantae')
kingdom = TaxonConcept.create(:rank_id => Rank.find_by_name('Kingdom').id,
  :taxon_name_id => name.id, :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Violales')
order = TaxonConcept.create(:rank_id => Rank.find_by_name('Order').id,
  :taxon_name_id => name.id, :parent_id => kingdom.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Violaceae')
family = TaxonConcept.create(:rank_id => Rank.find_by_name('Family').id,
  :taxon_name_id => name.id, :parent_id => order.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Viola')
genus = TaxonConcept.create(:rank_id => Rank.find_by_name('Genus').id,
  :taxon_name_id => name.id, :parent_id => family.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Viola montana L.')
viola_montana = TaxonConcept.create(:rank_id => Rank.find_by_name('Species').id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Viola canina L.')
viola_canina = TaxonConcept.create(:rank_id => Rank.find_by_name('Species').id,
  :taxon_name_id => name.id, :parent_id => genus.id,
  :designation_id => cites.id)
name = TaxonName.create(:scientific_name => 'Viola canina L. ssp. montana (L.) Hartman')
viola_canina_ssp = TaxonConcept.create(:rank_id => Rank.find_by_name('Subspecies').id,
  :taxon_name_id => name.id, :parent_id => viola_canina.id,
  :designation_id => cites.id)

TaxonRelationship.create(
  :taxon_concept_id => viola_montana.id, :other_taxon_concept_id => viola_canina_ssp.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name('is_synonym').id
)
TaxonRelationship.create(
  :taxon_concept_id => viola_canina_ssp.id, :other_taxon_concept_id => viola_montana.id,
  :taxon_relationship_type_id => TaxonRelationshipType.find_by_name('is_synonym').id
)