
def check_file_provided(task_name)
  if ENV['FILE'].blank?
    fail "Usage: FILE=/abs/path/to/file rake elibrary:import:#{task_name}"
  end
end

namespace :elibrary do
  task :clear => :environment do
    puts "Deleting citations"
    DocumentCitationGeoEntity.delete_all
    DocumentCitationTaxonConcept.delete_all
    DocumentCitation.delete_all
    puts "Deleting documents"
    DocumentTag.delete_all
    Document::ProposalDetails.delete_all
    Document::ReviewDetails.delete_all
    Document.delete_all
  end

  namespace :non_cites_taxa do
    require Rails.root.join('lib/tasks/elibrary/non_cites_taxa_importer.rb')
    desc 'Import non-CITES taxa from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::NonCitesTaxaImporter.new(ENV['FILE'])
      importer.run
    end
  end

  namespace :events do
    require Rails.root.join('lib/tasks/elibrary/events_importer.rb')
    desc 'Import events from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::EventsImporter.new(ENV['FILE'])
      importer.run
    end
  end
end