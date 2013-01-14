#paste into rails console to add current Listing distribution for loxodonta africana
tc = TaxonConcept.where(:full_name => 'Loxodonta africana').first
#find the current listing changes
lc1 = tc.listing_changes.where(:effective_at => '1990-01-18').first
lc2 = tc.listing_changes.where(:effective_at => '2007-09-13').first

#Populations of BW, NA, ZA, ZW
bw = GeoEntity.find_by_iso_code2('Bw')
na = GeoEntity.find_by_iso_code2('Na')
za = GeoEntity.find_by_iso_code2('Za')
zw = GeoEntity.find_by_iso_code2('Zw')

#add listing distributions
ListingDistribution.create(
  :listing_change_id => lc2.id,
  :geo_entity_id => bw.id,
  :is_party => false
)
ListingDistribution.create(
  :listing_change_id => lc2.id,
  :geo_entity_id => na.id,
  :is_party => false
)
ListingDistribution.create(
  :listing_change_id => lc2.id,
  :geo_entity_id => za.id,
  :is_party => false
)
ListingDistribution.create(
  :listing_change_id => lc2.id,
  :geo_entity_id => zw.id,
  :is_party => false
)