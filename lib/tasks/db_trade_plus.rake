namespace :db do
  namespace :trade_plus do
    task :rebuild => :environment do
      Trade::RebuildTradePlusViews.run
    end
  end
end
