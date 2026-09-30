# One page: what is loaded, what points at something missing, what has been
# uploaded lately, and the form that uploads the next one.
#
# The upload itself is Admin::TaxonMappings::UploadsController - a file arriving
# is a different thing from the page that reports on it.
class Admin::TaxonMappingsController < Admin::AdminController
  include TaxonMappingAccess

  IMPORTS_PER_PAGE = 10

  def index
    taxonomies = MatchableTaxonomy.order(:code).to_a
    taxa = MappingTaxon.summary_by_taxonomy
    pairs = MappingMatch.summary_by_pair

    @taxonomy_rows =
      taxonomies.map do |taxonomy|
        { taxonomy: taxonomy }.merge(taxa[taxonomy.id] || {})
      end

    # Every combination is listed, loaded or not. A blank row is the only thing
    # that shows a lookup will come back empty because nobody uploaded that
    # file; the API cannot distinguish that from a taxon with no counterpart.
    @pair_rows =
      taxonomies.combination(2).map do |near, far|
        { near: near, far: far }.merge(pairs[[ near.id, far.id ].sort] || {})
      end

    # A platform whose taxa were never uploaded makes every match on that side
    # unresolved. That is a missing upload rather than a bad reference, and the
    # table above already says so - flagged here rather than counted.
    @unresolved_rows =
      MappingMatch.unresolved_by_source.map do |row|
        row.merge(
          taxonomy: taxonomies.find { |t| t.id == row[:matchable_taxonomy_id] },
          taxa_loaded: taxa.key?(row[:matchable_taxonomy_id])
        )
      end

    @taxonomy_options = taxonomies.map { |t| [ "#{t.code} - #{t.name}", t.id ] }

    @imports =
      Import.of_kind(Imports::MappingJob::KINDS).recent
        .includes(:creator, file_attachment: :blob)
        .page(params[:page]).per(IMPORTS_PER_PAGE)
    # A running import finishes in the background, so the page has to come back
    # on its own or it goes stale in front of whoever started it.
    @running_imports = @imports.any? { |import| import.pending? || import.running? }
  end
end
