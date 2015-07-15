
def check_file_provided(task_name)
  if ENV['FILE'].blank?
    fail "Usage: FILE=/abs/path/to/file rake elibrary:import:#{task_name}"
  end
end

namespace :elibrary do
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