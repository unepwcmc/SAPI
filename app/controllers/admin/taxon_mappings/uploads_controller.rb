# Block A of the Taxon Mapping page: hand a file to a background job.
#
# All this does is build the Import row. What the row means, which importers it
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
  # Import is generic, and a mapping upload is the only kind that needs two of
  # them. Checked here so the admin is told before a job is queued rather than
  # finding a failed row afterwards.
  def rejection_reason(import)
    return 'Choose the taxonomy this file belongs to.' if import.importable.nil?
    return nil unless import.kind == 'mapping_matches'

    far = MatchableTaxonomy.find_by(id: import.params['foreign_matchable_taxonomy_id'])

    return 'Choose the second taxonomy a match file relates.' if far.nil?
    # Replacing a pair with itself would clear the platform's matches against
    # every other one, because the scope is written in both orientations.
    return 'A match file relates two different taxonomies.' if far == import.importable

    nil
  end

  def build_import
    Import.new(
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
