# One run, opened from the timestamp beside whatever it loaded.
#
# The page's tables say when a taxonomy or a pair was last loaded; this says
# what that was - which file, who sent it, how it went, and the file itself to
# download. None of which fits in a table cell.
class Admin::TaxonMappings::ImportRunsController < Admin::AdminController
  include TaxonMappingAccess

  respond_to :js, only: [ :show ]

  def show
    @import_run = find_run
  end

  # Through here rather than a link straight to the blob: rails_blob_path signs
  # a URL that never expires and asks nobody for credentials, so it would hand
  # out the file to anyone it reached. The same warning is written on the three
  # document controllers. One minute is long enough to follow a redirect.
  def download
    run = find_run

    return head :not_found unless run.file.attached?

    redirect_to run.file.url(disposition: 'attachment', expires_in: 1.minute),
      allow_other_host: true
  end

private

  def find_run
    ImportRun.of_kind(Imports::MappingJob::KINDS).find(params[:id])
  end
end
