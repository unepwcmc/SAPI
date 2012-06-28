# this hack comes from SO:
# http://stackoverflow.com/questions/2015473/using-factory-girl-in-rails-with-associations-that-have-unique-constraints-gett/3569062#3569062
# and is intended to allow easy reuse of lookup data defined in seeds
saved_single_instances = {}
#Find or create the model instance
single_instances = lambda do |factory_key|
  begin
    saved_single_instances[factory_key].reload
  rescue NoMethodError, ActiveRecord::RecordNotFound  
    #was never created (is nil) or was cleared from db
    saved_single_instances[factory_key] = FactoryGirl.create(factory_key)  #recreate
  end

  return saved_single_instances[factory_key]
end
FactoryGirl.define do

  factory :species_listing do |f|
    f.name 'Appendix X'
    f.abbreviation 'X'
    f.association :designation
  end
  
  factory :cites_species_listing, parent: :species_listing, class: SpeciesListing do |f|
    f.designation { Designation.find_by_name('CITES') }
  end

  factory :listing_change do |f|
    f.association :species_listing
    f.association :change_type
    f.association :taxon_concept
    f.association :party, factory: :country
    f.effective_at '2012-01-01'
  end

  factory :cites_listing_change, parent: :listing_change, class: ListingChange do |f|
    f.species_listing { single_instances[:cites_species_listing] }
  end

  %w(I II III).each do |a|

    factory :"cites_#{a}_listing_change", parent: :cites_listing_change, class: ListingChange do |f|
      f.species_listing { SpeciesListing.find_by_abbreviation(a) }
    end
    %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL).each do |ch|
      factory :"cites_#{a}_#{ch.downcase}", parent: :"cites_#{a}_listing_change", class: ListingChange do |f|
        f.change_type { ChangeType.find_by_name(ch) }
      end
    end
  end
end