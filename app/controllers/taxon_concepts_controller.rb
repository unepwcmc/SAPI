class TaxonConceptsController < ApplicationController

  def index
    render :json => Checklist::Checklist.new(params).
      generate(params[:page], params[:per_page])
  end

  def autocomplete
    taxon_concepts = MTaxonConcept.by_designation('CITES').
      without_nc.
      select("
        full_name, rank_name,
        ARRAY(
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
        ) AS synonyms_ary,
        ARRAY(
          SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE '%#{params[:scientific_name]}%'
        ) AS english_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(french_names_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
        ) AS french_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
        ) AS spanish_names_ary"
      ).
      where("
        full_name ILIKE '#{params[:scientific_name]}%'
        OR
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
          UNION
          SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE '%#{params[:scientific_name]}%'
          UNION
          SELECT * FROM UNNEST(french_names_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
          UNION
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
        )
      ").
      limit(params[:per_page]).
      order("LENGTH(taxonomic_position), full_name")
    render :json => taxon_concepts.to_json(:methods => [:full_name, :rank_name, :matching_names])
  end

  def summarise_filters
    render :text => Checklist::Checklist.new(@checklist_params).summarise_filters
  end

end
