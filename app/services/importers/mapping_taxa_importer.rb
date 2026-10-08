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
      'Rank' => :rank_id,
      'Scientific.Name' => :scientific_name,
      'Author' => :author_year
    }
  )

  derived_attributes %i[matchable_taxonomy_id import_run_id]

  attr_reader :matchable_taxonomy, :import_run

  # The run is recorded on every row rather than the file's name: two uploads
  # can share a name, and the path the file is read from is an ActiveStorage
  # tempfile called nothing anyone could re-export. The run holds the file, so
  # its name is still reachable - just said once.
  def initialize(file_path:, matchable_taxonomy:, import_run:)
    super(file_path: file_path)
    @matchable_taxonomy = matchable_taxonomy
    @import_run = import_run
  end

  private

  # Which platform the file belongs to is the admin's choice on the upload
  # form, not something the file declares - `cites.csv` is a filename, and a
  # match file does not even say which of its two platforms is which.
  def cast_matchable_taxonomy_id(_raw_value)
    matchable_taxonomy.id
  end

  def cast_import_run_id(_raw_value)
    import_run.id
  end

  # Rank arrives as a name - SPECIES, SUBSPECIES - and has to become a ranks.id.
  #
  # Not resolve_belongs_to, which is the framework's way of doing this: it
  # raises on a name it cannot find, and these files legitimately carry ranks
  # this application does not model. The Red List alone uses FORMA on 315 names
  # and SUBSPECIES (PLANTAE) on 2,601, and `ranks` is Species+ taxonomy shared
  # with the rest of the app, so it is not ours to add to. Those names are worth
  # importing without a rank rather than not importing at all.
  def cast_rank_id(raw_value)
    name = raw_value.to_s.strip.upcase

    return nil if name.empty? || name == 'NA'

    rank_ids.fetch(name) { unknown_rank(name) }
  end

  # `ranks` is a ten-row dictionary, so one query serves the whole run.
  def rank_ids
    @rank_ids ||= Rank.pluck(:name, :id).to_h { |name, id| [ name.upcase, id ] }
  end

  # Reported once per distinct name. At one line per row the two Red List ranks
  # above would bury every other entry in a log that is read in the browser.
  def unknown_rank(name)
    return nil unless reported_ranks.add?(name)

    log_warning(message: "no rank named #{name}; those names are imported without one")
    nil
  end

  def reported_ranks
    @reported_ranks ||= Set.new
  end
end
