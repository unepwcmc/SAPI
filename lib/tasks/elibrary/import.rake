
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
    Document::ProposalDetails.delete_all
    Document::ReviewDetails.delete_all
    Document.delete_all
    DocumentTag.delete_all
  end

  namespace :document_tags do
    desc 'Import missing document tags'
    task :import => :environment do
      puts "#{DocumentTag.count} document tags"

      [
        "I", "II", "III", "IV", "June 1986", "None",
        "Post-CoP11", "Post-CoP12", "Post-CoP13"
      ].each { |tag| DocumentTag::ReviewPhase.find_or_create_by(name: tag) }

      [
        "AC review and categorization (k)", "AC review and categorization [k]",
        "AC review (e)", "AC review [e]", "Categorise information (i)", "Consulation (d)",
        "PC review and categorization [k]", "PC review and categorization (m)", "PC review (e)",
        "Research of species [j]", "Selection of species (b)", "Selection of species [b]",
        "Species selection (b)", "Species selection [b]"
      ].each { |tag| DocumentTag::ProcessStage.find_or_create_by(name: tag) }

      [
        "Accepted", "Cancelled", "Deferred",
        "Redundant", "Rejected", "Transferred to other proposals",
        "Withdrawn", "Accepted as amended", "Rejected as amended",
        "Adopted"
      ].each { |tag| DocumentTag::ProposalOutcome.find_or_create_by(name: tag) }

      puts "#{DocumentTag.count} document tags"
    end
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
  namespace :documents do
    require Rails.root.join('lib/tasks/elibrary/documents_importer.rb')
    desc 'Import documents from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::DocumentsImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :identification_documents do
    require Rails.root.join('lib/tasks/elibrary/documents_identification_importer.rb')
    desc 'Import manual id documents and VC resources from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::DocumentsIdentificationImporter.new(ENV['FILE'])
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
  namespace :manual_document_files do
    require Rails.root.join('lib/tasks/elibrary/manual_document_files_importer.rb')
    desc 'Import Manual ID and Virtual College files'
    task :import => :environment do |task_name|
      if ENV['SOURCE_DIR'].blank? || ENV['TARGET_DIR'].blank?
        fail "Usage: SOURCE_DIR=/abs/path/to/dir TARGET_DIR=/abs/path/to/dir rake elibrary:import:#{task_name}"
      end
      importer = Elibrary::ManualDocumentFilesImporter.new(ENV['SOURCE_DIR'], ENV['TARGET_DIR'])
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
  namespace :citations_manual do
    require Rails.root.join('lib/tasks/elibrary/citations_manual_importer.rb')
    desc 'Import Manual ID and VC citations from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::CitationsManualImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :identification_distribution do
    require Rails.root.join('lib/tasks/elibrary/identification_docs_distributions_importer.rb')
    desc 'Import taxon distributions on Identification documents'
    task :import => :environment do |task_name|
      Elibrary::IdentificationDocsDistributionsImporter.run
    end
  end
end
