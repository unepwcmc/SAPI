namespace :species_without_legislation_or_trade do

  task :export => :environment do
    Trade::SpeciesWithoutLegislationOrTradeReport.new.export('tmp/species_to_delete.csv')
  end

  task :delete => :environment do
    cnt = Trade::SpeciesWithoutLegislationOrTradeReport.new.query.count
    deleted_cnt = 0
    Rails.logger.warn("### BEGIN removal of #{cnt} species without legislation or trade")
    Trade::SpeciesWithoutLegislationOrTradeReport.new.query.each do |tc|
      if tc.destroy
        Rails.logger.warn("### DESTROY #{tc.id} #{tc.full_name} SUCCESS")
        deleted_cnt += 1
      else
        Rails.logger.error("### DESTROY #{tc.id} #{tc.full_name} ERROR #{tc.errors.messages[:base]}")
      end
    end
    Rails.logger.warn("### END removal of #{deleted_cnt} species without legislation or trade")
  end

end
