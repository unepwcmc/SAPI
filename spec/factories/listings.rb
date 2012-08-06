FactoryGirl.define do

  factory :species_listing do
    name 'Appendix X'
    abbreviation 'X'
    designation
  end

  factory :change_type do
    name 'ADDITION'
  end

  factory :listing_change do
    species_listing
    change_type
    taxon_concept
    effective_at '2012-01-01'
  end

  factory :listing_distribution do
    geo_entity
    is_party true
  end

  factory :cites_deletion, class: ListingChange do
    change_type { ChangeType.find_by_name('DELETION') }
    taxon_concept
  end

  %w(I II III).each do |a|
    factory :"cites_#{a}_listing_change", parent: :listing_change, class: ListingChange do
      species_listing { SpeciesListing.find_by_abbreviation(a) }
    end
    %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL).each do |ch|
      factory :"cites_#{a}_#{ch.downcase}", parent: :"cites_#{a}_listing_change", class: ListingChange do
        change_type { ChangeType.find_by_name(ch) }
      end
    end
  end
end