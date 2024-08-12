namespace :rst_processes do
  desc 'Import RST(Significant Trade) cases from RST API'
  task import: :environment do
    Import::Rst::RstCases.import_all
  end
end
