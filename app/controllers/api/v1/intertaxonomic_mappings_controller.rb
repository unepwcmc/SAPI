# Given a taxon in one platform, what it is in the others:
#
#   GET /api/v1/intertaxonomic_mappings/CITES_EU:68363?taxonomies=IUCNRL,GARD
#
# Public, like the other species endpoints. The rules behind the response -
# which matches are returned, how they are ranked, what an empty answer means -
# are in doc/intertaxonomic_mapping_api.md.
class Api::V1::IntertaxonomicMappingsController < ApplicationController
  def show
    taxonomy_code, taxon_nid = params[:id].split(':', 2)
    raise ActionController::BadRequest if taxon_nid.blank?

    taxonomy = MatchableTaxonomy.find_by(code: taxonomy_code)
    foreign_taxonomies = requested_taxonomies
    return head :not_found if taxonomy.nil? || foreign_taxonomies == :not_found

    taxon = MappingTaxon.lookup(matchable_taxonomy: taxonomy, taxon_nid: taxon_nid).first
    matches =
      MappingMatch.resolve(
        matchable_taxonomy: taxonomy,
        taxon_nid: taxon_nid,
        foreign_matchable_taxonomies: foreign_taxonomies
      ).includes(:foreign_matchable_taxonomy)

    render json: {
      taxon: {
        taxonomy: taxonomy.code,
        taxon_nid: taxon_nid,
        # An id we do not hold is still answered: the taxa exports are not a
        # complete record of each platform, so it may yet have matches.
        scientific_name: taxon&.scientific_name,
        author_year: taxon&.author_year
      },
      mappings: ranked(matches).map { |match, rank| mapping_json(match, rank) }
    }
  end

private

  # nil when the caller did not narrow the platforms, :not_found when any code
  # they named is not registered - a typo should not read as "no matches".
  def requested_taxonomies
    codes = params[:taxonomies].to_s.split(',').map(&:strip).compact_blank.uniq
    return nil if codes.empty?

    taxonomies = MatchableTaxonomy.where(code: codes).to_a
    taxonomies.size == codes.size ? taxonomies : :not_found
  end

  # Ranked within each platform, 1 being the match the NDF tool uses by
  # default. Ties on match type and confidence fall back to the accepted name,
  # so the order is stable between requests.
  def ranked(matches)
    matches.group_by(&:foreign_matchable_taxonomy).sort_by { |taxonomy, _| taxonomy.code }.flat_map do |_, group|
      group.sort_by { |match| [ *match.precedence, match.foreign_scientific_name ] }.each.with_index(1).to_a
    end
  end

  def mapping_json(match, rank)
    {
      taxonomy: match.foreign_matchable_taxonomy.code,
      taxon_nid: match.foreign_taxon_nid,
      scientific_name: match.foreign_scientific_name,
      author_year: match.foreign_author_year,
      rank: rank,
      match_type: match.match_type,
      match_confidence: match.confidence_score,
      matched_name: match.matched_name,
      foreign_matched_name: match.foreign_matched_name
    }
  end
end
