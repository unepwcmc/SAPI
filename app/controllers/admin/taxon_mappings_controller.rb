# One page: what is loaded, what points at something missing, what has been
# uploaded lately, and the form that uploads the next one.
#
# The upload itself is Admin::TaxonMappings::UploadsController - a file arriving
# is a different thing from the page that reports on it.
class Admin::TaxonMappingsController < Admin::AdminController
  include TaxonMappingAccess
  include TaxonMappingImports

  def index
    load_summary
    load_imports

    @taxonomy_options =
      MatchableTaxonomy.order(:code).map { |t| [ "#{t.code} - #{t.name}", t.id ] }
  end
end
