class Api::V1::AutoCompleteTaxonConceptsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :taxon_concept_sweeper

  def index
    matcher = Species::TaxonConceptPrefixMatcher.new(params)
    @taxon_concepts = matcher.taxon_concepts.limit(params[:per_page])
    render :json => @taxon_concepts,
      :each_serializer => Species::AutocompleteTaxonConceptSerializer,
      :meta => {
        :total => matcher.taxon_concepts.count,
        :rank_headers => @taxon_concepts.map(&:rank_name).uniq.map do |r|
          {
            :rank_name => r, 
            :taxon_concept_ids => @taxon_concepts.select{|tc| tc.rank_name == r}.map(&:id)
          }
        end
      }
  end

end
