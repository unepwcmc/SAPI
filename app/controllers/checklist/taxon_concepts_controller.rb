class Checklist::TaxonConceptsController < ApplicationController

  def index
    checklist = Checklist::Checklist.new(params)

    render :json => checklist.generate,
      :each_serializer => Checklist::ChecklistSerializer,
      :authors => checklist.authors,
      :synonyms => checklist.synonyms,
      :english_names => checklist.english_common_names,
      :spanish_names => checklist.spanish_common_names,
      :french_names => checklist.french_common_names
  end

  def autocomplete
    matcher = Species::TaxonConceptPrefixMatcher.new(
      :taxon_concept_query => params[:scientific_name],
      :per_page => params[:per_page]
    )
    render :json => matcher.cached_results.
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
