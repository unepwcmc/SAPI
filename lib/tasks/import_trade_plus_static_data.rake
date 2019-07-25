require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc 'import trade plus static data (usage: rake import:trade_plus_static_data[path/to/file])'
  task :trade_plus_static_data, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    files = files_from_args(t, args)
    files.each do |file|
      sql = <<-SQL
        COPY trade_plus_static(year,appendix,taxon_name,taxon_id,group_name,class_name,order_name,family_name,genus_name,importer,exporter,origin,importer_reported_quantity,exporter_reported_quantity,term,term_converted,unit,unit_converted,purpose,source)
        FROM '#{Rails.application.root}/#{file}' DELIMITER ',' CSV HEADER
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
