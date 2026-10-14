# The two blocks of the Taxon Mapping page that are refreshed without reloading
# it: what is loaded, and what has been uploaded lately. Each is rendered both
# by the page itself and by the endpoint its JavaScript fetches, so they live
# here rather than in one controller the other would have to copy.
module TaxonMappingImports
  extend ActiveSupport::Concern

  PER_PAGE = 10

  private

  # Blocks B and C. Every number here moves when an import finishes, which is
  # why they are fetched together and only then - the taxa summary groups over
  # every name a platform holds, and the unresolved counts scan the matches
  # twice, so asking on a timer would be work for nothing.
  def load_summary
    taxonomies = MatchableTaxonomy.order(:code).to_a
    taxa = MappingTaxon.summary_by_taxonomy
    pairs = MappingMatch.summary_by_pair

    @taxonomy_rows =
      taxonomies.map { |taxonomy| { taxonomy: taxonomy }.merge(taxa[taxonomy.id] || {}) }

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

    name_the_runs(@taxonomy_rows, @pair_rows, @unresolved_rows)
  end

  # Rows carry the run that wrote them, not the file's name, so the runs are
  # resolved once here rather than a row at a time in the template.
  def name_the_runs(*row_sets)
    runs =
      ImportRun.where(id: row_sets.flatten.filter_map { |row| row[:import_run_id] }.uniq)
        .includes(file_attachment: :blob).index_by(&:id)

    row_sets.flatten.each { |row| row[:import_run] = runs[row[:import_run_id]] }
  end

  def load_imports
    @imports =
      ImportRun.of_kind(Imports::MappingJob::KINDS).recent
        .includes(:creator, file_attachment: :blob)
        .page(params[:page]).per(PER_PAGE)
    # What the poll reads to decide whether to ask again. An import outlives
    # the request that started it, so the block is only current while
    # something is still working.
    @running_imports = @imports.any? { |import| import.pending? || import.running? }
  end
end
