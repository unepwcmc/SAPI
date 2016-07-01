class Api::V1::AutoCompleteTaxonConceptsController < ApplicationController

  def index
    params['ranks'] ||= []
    matcher = Species::TaxonConceptPrefixMatcher.new params
    @taxon_concepts = matcher.cached_results
    render :json => @taxon_concepts,
      :each_serializer => Species::AutocompleteTaxonConceptSerializer,
      :meta => {
        :total => matcher.cached_total_cnt,
        :rank_headers => @taxon_concepts.map(&:rank_display_name).uniq.map do |r|
          {
            :rank_name => r,
            :taxon_concept_ids => @taxon_concepts.select { |tc| tc.rank_display_name == r }.map(&:id)
          }
        end
      }
  end

end
