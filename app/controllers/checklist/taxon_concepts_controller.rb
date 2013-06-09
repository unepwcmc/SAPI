class Checklist::TaxonConceptsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :taxon_concept_sweeper

  def index
    render :json => Checklist::Checklist.new(params).
      generate(params[:page], params[:per_page])
  end

  def autocomplete
    matcher = Checklist::TaxonConceptPrefixMatcher.new(
      :scientific_name => params[:scientific_name]
    )
    render :json => matcher.taxon_concepts.limit(params[:per_page]).
      to_json(:methods => [:full_name, :rank_name, :matching_names])
  end

  def summarise_filters
    render :text => Checklist::Checklist.new(params).summarise_filters
  end
end
