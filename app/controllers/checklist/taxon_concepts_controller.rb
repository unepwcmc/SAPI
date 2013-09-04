class Checklist::TaxonConceptsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :taxon_concept_sweeper

  def index
    checklist = Checklist::Checklist.new(params)
      
    render :json => checklist.generate(params[:page], params[:per_page]),
      :each_serializer => Checklist::ChecklistSerializer,
      :authors => checklist.authors,
      :synonyms => checklist.synonyms,
      :english_names => checklist.english_names,
      :spanish_names => checklist.spanish_names,
      :french_names => checklist.french_names
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

  private
  # this disables json root for this controller
  # remove when checklist frontend upgraded to new Ember.js
  def default_serializer_options
    {
      root: false
    }
  end

end
