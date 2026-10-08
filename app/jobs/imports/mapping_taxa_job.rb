# taxonomies/<platform>.csv - every name one platform publishes.
class Imports::MappingTaxaJob < Imports::MappingJob
  private

  def load(path)
    Mapping::FileImport.taxa(
      file_path: path, matchable_taxonomy: import_run.importable, import_run: import_run
    )
  end
end
