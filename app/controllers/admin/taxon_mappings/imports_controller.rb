# Just the recent-imports block of the Taxon Mapping page.
#
# Polled while an import runs, so the block stays current without reloading the
# page - which would throw away a half-filled upload form, and a chosen file
# cannot be put back by script afterwards.
class Admin::TaxonMappings::ImportsController < Admin::AdminController
  include TaxonMappingAccess
  include TaxonMappingImports

  def index
    load_imports

    render partial: 'admin/taxon_mappings/imports', layout: false
  end
end
