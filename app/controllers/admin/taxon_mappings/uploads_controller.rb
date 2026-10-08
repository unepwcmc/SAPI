# Block A of the Taxon Mapping page: hand a file to a background job.
#
# All this does is build the ImportRun row. What the row means, which importers it
# runs and what it clears first is the job's business - see Imports::MappingJob.
class Admin::TaxonMappings::UploadsController < Admin::AdminController
  include TaxonMappingAccess

  def create
    import = build_import

    if (problem = rejection_reason(import))
      redirect_to admin_taxon_mappings_path, alert: problem
    elsif import.save
      redirect_to admin_taxon_mappings_path,
        notice: "#{import.filename} queued. It will appear below when it finishes."
    else
      redirect_to admin_taxon_mappings_path, alert: import.errors.full_messages.to_sentence
    end
  end

private

  # Which taxonomies a file is about is the page's question, not the table's -
  # ImportRun is generic, and a mapping upload is the only kind that needs two of
  # them. Checked here so the admin is told before a job is queued rather than
  # finding a failed row afterwards.
  def rejection_reason(import)
    return 'Choose the taxonomy this file belongs to.' if import.importable.nil?

    if import.kind == 'mapping_matches'
      far = MatchableTaxonomy.find_by(id: import.params['foreign_matchable_taxonomy_id'])

      return 'Choose the second taxonomy a match file relates.' if far.nil?
      # Replacing a pair with itself would clear the platform's matches against
      # every other one, because the scope is written in both orientations.
      return 'A match file relates two different taxonomies.' if far == import.importable
    end

    already_running(import)
  end

  # An upload clears everything already held for what it names before inserting,
  # so two of them aimed at the same thing cannot both be right. Left to run,
  # the second would sit on the first's row locks until the ten-second
  # lock_timeout and die with a message about Postgres rather than about files.
  #
  # Unrelated uploads are deliberately left alone: a taxa file for CITES and one
  # for IUCN share nothing, and a large import takes minutes.
  def already_running(import)
    mine = ImportRun.unfinished.of_kind(Imports::MappingJob::KINDS)
    other = mine.find { |run| same_scope?(run, import) }

    return nil if other.nil?

    "#{other.filename} is still being imported into #{scope_name(import)}. " \
      'Wait for it to finish, then upload again.'
  end

  # The same scope, not the same file: what matters is what the upload replaces.
  # A match file names an unordered pair, so CITES to IUCN and IUCN to CITES are
  # one scope and have to compare equal whichever way round each was uploaded.
  def same_scope?(other, import)
    other.kind == import.kind && scope_key(other) == scope_key(import)
  end

  def scope_key(import)
    far_id = import.params['foreign_matchable_taxonomy_id']

    [ import.importable_id, far_id.presence&.to_i ].compact.sort
  end

  def scope_name(import)
    helpers.import_target(import)
  end

  def build_import
    ImportRun.new(
      kind: upload_params[:kind],
      importable: MatchableTaxonomy.find_by(id: upload_params[:matchable_taxonomy_id]),
      params: job_params,
      creator: current_user
    ).tap { |import| import.file.attach(upload_params[:file]) if upload_params[:file].present? }
  end

  # The far side is carried in params rather than a second association because
  # importable holds one record and a match file is about two. Only the match
  # kind has one, and the two sides have to differ - replacing a pair with
  # itself would wipe the platform's matches against everything else.
  def job_params
    return {} unless upload_params[:kind] == 'mapping_matches'

    { 'foreign_matchable_taxonomy_id' => upload_params[:foreign_matchable_taxonomy_id] }
  end

  def upload_params
    @upload_params ||=
      params.expect(
        upload: [ :kind, :matchable_taxonomy_id, :foreign_matchable_taxonomy_id, :file ]
      )
  end
end
