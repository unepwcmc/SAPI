FactoryGirl.define do

  factory :species_listing do |f|
    f.name 'Appendix X'
    f.abbreviation 'X'
    f.association :designation
  end

  factory :listing_change do |f|
    f.association :species_listing
    f.association :change_type
    f.association :taxon_concept
    f.effective_at '2012-01-01'
  end

  factory :listing_distribution do |f|
    f.association :geo_entity
    f.is_party true
  end

  factory :cites_deletion, class: ListingChange do |f|
    f.change_type { ChangeType.find_by_name('DELETION') }
    f.association :taxon_concept
  end

  %w(I II III).each do |a|
    factory :"cites_#{a}_listing_change", parent: :listing_change, class: ListingChange do |f|
      f.species_listing { SpeciesListing.find_by_abbreviation(a) }
    end
    %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL).each do |ch|
      factory :"cites_#{a}_#{ch.downcase}", parent: :"cites_#{a}_listing_change", class: ListingChange do |f|
        f.change_type { ChangeType.find_by_name(ch) }
      end
    end
  end
end