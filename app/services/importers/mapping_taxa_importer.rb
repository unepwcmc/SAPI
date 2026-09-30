# taxonomies/<platform>.csv -> mapping_taxa. One file, one platform.
#
# Every name goes in, accepted and synonym alike, so a match can later show
# which names it was made on. The caller clears the platform's existing rows
# first; see MappingTaxon.import_scope.
class Importers::MappingTaxaImporter < Importer::Base
  target_model MappingTaxon
  mode :raw_insert_all
  batch_size 5_000

  # Id and Id_Accepted are both nullable at the database: IUCN issues no
  # identifier for a synonym, and a handful of WoRMS rows are nomina nuda with
  # nothing to point at. Blank cells reach the column as NULL rather than '',
  # which Importer::RowTransformer's default cast already does.
  required_headers(
    {
      'Id' => :taxon_nid,
      'Id_Accepted' => :accepted_taxon_nid,
      'Status' => :name_status,
      'Scientific.Name' => :scientific_name,
      'Author' => :author_year
    }
  )

  derived_attributes %i[matchable_taxonomy_id rank_id source_file]

  attr_reader :matchable_taxonomy, :source_file

  # source_file is the name the file arrived under, which is not the path it is
  # read from: an upload reaches disk as an ActiveStorage tempfile, and
  # `ActiveStorage-16851-...xlsx` names nothing anyone can re-export.
  def initialize(file_path:, matchable_taxonomy:, source_file: nil)
    super(file_path: file_path)
    @matchable_taxonomy = matchable_taxonomy
    @source_file = source_file || File.basename(file_path)
  end

  private

  # Which platform the file belongs to is the admin's choice on the upload
  # form, not something the file declares - `cites.csv` is a filename, and a
  # match file does not even say which of its two platforms is which.
  def cast_matchable_taxonomy_id(_raw_value)
    matchable_taxonomy.id
  end

  def cast_source_file(_raw_value)
    source_file
  end

  # Stage 1 does not emit a Rank column yet. The column is nullable for exactly
  # this reason; when the export carries it, Rank moves into required_headers
  # and this caster resolves it against the ranks table.
  def cast_rank_id(_raw_value)
    nil
  end
end
