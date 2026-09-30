# taxonomies/<platform>.csv - every name one platform publishes.
class Imports::MappingTaxaJob < Imports::MappingJob
  private

  def load(path, source_file)
    Mapping::FileImport.taxa(
      file_path: path, matchable_taxonomy: import.importable, source_file: source_file
    )
  end
end
