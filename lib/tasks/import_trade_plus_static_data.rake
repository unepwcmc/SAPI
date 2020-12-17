require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc 'import trade plus static data (usage: rake import:trade_plus_static_data[path/to/file])'
  task :trade_plus_static_data, [:path_to_file] => [:environment] do |t, args|
    abort('File not provided.') unless args[:path_to_file]

    path_to_file = "#{Rails.application.root}/#{args[:path_to_file]}"
    abort("File doesn't exist.") unless File.exists?(path_to_file)

    COLUMNS = %w(
      id origin_iso importer_iso exporter_iso year appendix taxon_name group_name taxon_id
      class_name order_name family_name genus_name term term_converted unit unit_converted
      purpose source importer_reported_quantity exporter_reported_quantity
      exporter importer origin kingdom_name phylum_name
    ).freeze

    sql = <<-SQL
      COPY trade_plus_static(#{COLUMNS.join(',')})
      FROM '#{path_to_file}' DELIMITER ',' CSV HEADER
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end
end
