
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

  namespace :events do
    require Rails.root.join('lib/tasks/elibrary/events_importer.rb')
    desc 'Import events from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::EventsImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :documents do
    require Rails.root.join('lib/tasks/elibrary/documents_importer.rb')
    desc 'Import documents from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::DocumentsImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :document_discussions do
    require Rails.root.join('lib/tasks/elibrary/document_discussions_importer.rb')
    desc 'Import document discussions'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::DocumentDiscussionsImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :document_files do
    require Rails.root.join('lib/tasks/elibrary/document_files_importer.rb')
    desc 'Import document files'
    task :import => :environment do |task_name|
      if ENV['SOURCE_DIR'].blank? || ENV['TARGET_DIR'].blank?
        fail "Usage: SOURCE_DIR=/abs/path/to/dir TARGET_DIR=/abs/path/to/dir rake elibrary:import:#{task_name}"
      end
      importer = Elibrary::DocumentFilesImporter.new(ENV['SOURCE_DIR'], ENV['TARGET_DIR'])
      importer.run
    end
  end
  namespace :users do
    require Rails.root.join('lib/tasks/elibrary/users_importer.rb')
    desc 'Import users from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::UsersImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :citations_cop do
    require Rails.root.join('lib/tasks/elibrary/citations_cop_importer.rb')
    desc 'Import citations & proposal details from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::CitationsCopImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :citations_rst do
    require Rails.root.join('lib/tasks/elibrary/citations_rst_importer.rb')
    desc 'Import citations & review details from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::CitationsRstImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :citations_ndf do
    require Rails.root.join('lib/tasks/elibrary/citations_ndf_importer.rb')
    desc 'Import citations from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::CitationsNdfImporter.new(ENV['FILE'])
      importer.run
    end
  end
    namespace :citations_no_event do
    require Rails.root.join('lib/tasks/elibrary/citations_no_event_importer.rb')
    desc 'Import citations from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::CitationsNoEventImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :citations do
    require Rails.root.join('lib/tasks/elibrary/citations_importer.rb')
    desc 'Import citations from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::CitationsImporter.new(ENV['FILE'])
      importer.run
    end
  end
end