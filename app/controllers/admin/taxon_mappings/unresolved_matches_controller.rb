# The matches behind one of the numbers in the Taxon Mapping page's unresolved
# block. A count says an export has gone stale; this says which identifiers,
# which is what somebody can act on or send back upstream.
class Admin::TaxonMappings::UnresolvedMatchesController < Admin::AdminController
  include TaxonMappingAccess

  PER_PAGE = 50

  def index
    @taxonomy = MatchableTaxonomy.find(params[:matchable_taxonomy_id])
    @side = MappingMatch::SIDES.find { |side| side.to_s == params[:side] } || :near
    @source_file = params[:source_file].to_s

    @matches =
      MappingMatch.unresolved(
        side: @side, matchable_taxonomy: @taxonomy, source_file: @source_file
      ).includes(:matchable_taxonomy, :foreign_matchable_taxonomy)
        .page(params[:page]).per(PER_PAGE)
  end
end
