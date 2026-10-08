# What is loaded and what points at something missing - blocks B and C of the
# Taxon Mapping page, on their own.
#
# Fetched once when an import finishes, rather than on the timer that keeps the
# recent-imports block current: every number here moves together and only when
# a run ends, and working them out is not cheap.
class Admin::TaxonMappings::SummaryController < Admin::AdminController
  include TaxonMappingAccess
  include TaxonMappingImports

  def show
    load_summary

    render partial: 'admin/taxon_mappings/summary', layout: false
  end
end
