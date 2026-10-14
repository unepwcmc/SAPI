##
# Usage:
# bundle exec rails import:designation_geo_entities[lib/files/imports/2026-10-14/country-designations.csv]
namespace :import do
  # The file needs id, iso_code2, name_en and name (the geo entity type), plus
  # one t/f column per designation, named after it in lowercase - cites, cms.
  # Designations with no column are left alone. Any format Importer::Base
  # reads: .csv, .tsv, .xlsx, or a .zip holding one .csv/.tsv.
  desc 'Import which geo entities are Parties to each designation ' \
       '(usage: rake import:designation_geo_entities[path/to/Countries_CITES_CMS.csv], or .tsv/.xlsx/.zip)'
  task :designation_geo_entities, [ :file ] => [ :environment ] do |_t, args|
    file = args[:file] or abort 'usage: rake import:designation_geo_entities[path/to/file] (.csv, .tsv, .xlsx or .zip)'

    before = DesignationGeoEntity.joins(:designation).group('designations.name').count

    begin
      result = Importers::DesignationGeoEntitiesImporter.import_all!(file_path: file)
    rescue Importer::Base::ImportError => e
      abort "Nothing imported: #{e.message}"
    end

    after = DesignationGeoEntity.joins(:designation).group('designations.name').count

    result[:importers].each do |importer|
      name = importer.designation.name
      summary = importer.logs.find { |entry| entry[:message] == 'import completed' } || {}

      puts "#{name}: #{before.fetch(name, 0)} -> #{after.fetch(name, 0)} geo entities " \
           "(#{summary[:written]} listed as Parties, #{importer.removed_count} removed)"
    end

    result[:untouched].each do |designation|
      puts "#{designation.name}: no `#{Importers::DesignationGeoEntitiesImporter.column_for(designation)}` column, " \
           "left as it is (#{after.fetch(designation.name, 0)} geo entities)"
    end
  end
end
