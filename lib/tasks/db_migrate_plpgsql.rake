namespace :db do
  namespace :migrate do
    desc "Run custom sql scripts"
    task :sql => :environment do
      ApplicationRecord.transaction do
        connection = ApplicationRecord.connection

        ['helpers', 'mviews', 'plpgsql'].each do |dir|
          files = Dir.glob(Rails.root.join("db/#{dir}/*.sql"))

          files.sort.each do |file|
            puts "Executing #{file}"
            connection.execute(File.read(file))
          end
        end
      end
    end

    desc "Rebuild all computed values"
    task :rebuild => :migrate do
      SapiModule::rebuild
    end

    task :drop_indexes => :migrate do
      SapiModule::drop_indexes
    end

    task :create_indexes => :migrate do
      SapiModule::create_indexes
    end
  end

  task :migrate do
    Rake::Task['db:migrate:sql'].invoke
  end

  desc "Drop sandboxes in progress"
  task :drop_sandboxes => :environment do
    Trade::AnnualReportUpload.where(:is_done => false).each do |aru|
      aru.destroy
    end
  end

  desc "Drop all trade (shipments, permits, arus & sandboxes - use responsibly)"
  task :drop_trade => [:environment] do
    puts "Deleting shipments"
    ApplicationRecord.connection.execute('DELETE FROM trade_shipments')
    puts "Deleting permits"
    ApplicationRecord.connection.execute('DELETE FROM trade_permits')
    puts "Deleting annual report uploads & dropping sandboxes"
    Trade::AnnualReportUpload.all.each { |aru| aru.destroy }
  end
end
