class TaxonConceptsController < ApplicationController

  def index
    render :json => Checklist::Checklist.new(params).
      generate(params[:page], params[:per_page])
  end

  # def download_index
    # send_checklist_index_file
  # end
# 
  # def download_history
    # send_checklist_history_file
  # end

  def autocomplete
    taxon_concepts = MTaxonConcept.by_wildlife_trade_taxonomy.
      without_nc.
      select("
        DISTINCT id, LENGTH(taxonomic_position),
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
    render :text => Checklist::Checklist.new(params).summarise_filters
  end

  # private
  # def send_checklist_index_file
    # klass = if params[:format] == 'pdf'
      # Checklist::Pdf::Index
    # elsif params[:format] == 'csv'
      # Checklist::Csv::Index
    # elsif params[:format] == 'json'
      # Checklist::Json::Index
    # end
    # send_checklist_file(klass)
  # end
# 
  # def send_checklist_history_file
    # klass = if params[:format] == 'pdf'
      # Checklist::Pdf::History
    # elsif params[:format] == 'csv'
      # Checklist::Csv::History
    # elsif params[:format] == 'json'
      # Checklist::Json::History
    # end
    # send_checklist_file(klass)
  # end
# 
  # def send_checklist_file(klass)
    # checklist = klass.new(params)
    # @download_path = checklist.generate
    # send_file(@download_path,
      # :filename => checklist.download_name,
      # :type => checklist.ext)
    # FileUtils.rm @download_path
  # end

end
