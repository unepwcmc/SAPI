namespace :export do

  task :species_to_delete => :environment do
    Trade::SpeciesWithoutLegislationOrTradeReport.new.export('tmp/species_to_delete.csv')
  end

end
