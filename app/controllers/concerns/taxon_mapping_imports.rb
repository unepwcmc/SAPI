# The recent-imports block, which two controllers render: the page as a whole,
# and the endpoint its JavaScript polls to keep that one block current while a
# job runs. Shared so the two cannot drift into showing different things.
module TaxonMappingImports
  extend ActiveSupport::Concern

  PER_PAGE = 10

  private

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
