FactoryGirl.define do

  factory :species_listing do
    sequence(:name) {|n| "Appendix #{n}"}
    sequence(:abbreviation) {|n| "#{n}"}
    designation
  end

  factory :change_type do
    name 'ADDITION'
    designation
  end

  factory :listing_change do
    species_listing
    change_type
    taxon_concept
    effective_at '2012-01-01'
    #is_current false
    #inclusion_taxon_concept_id nil
    parent_id nil
  end

  factory :listing_distribution do
    geo_entity
    is_party true
  end

  factory :cites_deletion, class: ListingChange do
    change_type { ChangeType.find_by_name_and_designation_id('DELETION', Designation.find_by_name('CITES').id) }
    taxon_concept
  end

  %w(I II III).each do |a|
    factory :"cites_#{a}_listing_change", parent: :listing_change, class: ListingChange do
      species_listing { SpeciesListing.find_by_abbreviation(a) }
    end
    %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL).each do |ch|
      factory :"cites_#{a}_#{ch.downcase}", parent: :"cites_#{a}_listing_change", class: ListingChange do
        change_type { ChangeType.find_by_name_and_designation_id(ch, Designation.find_by_name('CITES').id) }
      end
      factory :"cites_#{a}_#{ch.downcase}_exception", parent: :"cites_#{a}_listing_change", class: ListingChange do
        change_type { ChangeType.find_by_name_and_designation_id('EXCEPTION', Designation.find_by_name('CITES').id) }
      end
    end
  end
end
