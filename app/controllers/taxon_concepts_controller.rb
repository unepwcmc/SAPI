class TaxonConceptsController < ApplicationController
  before_filter :extract_checklist_params

  def index
    render :json => Checklist.new(@checklist_params).
      generate(params[:page], params[:per_page])
  end

  def history
    render :json => ChecklistHistory.new(@checklist_params).
      generate(params[:page], params[:per_page])
  end

  def download
    job_id = DownloadWorker.perform_async(params[:type], params[:format], @checklist_params)

    render :json => {:id => job_id}
  end

  def autocomplete
    taxon_concepts = MTaxonConcept.by_designation('CITES').
      without_hidden.
      select("
        full_name, rank_name,
        ARRAY(
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
        ) AS synonyms_ary,
        ARRAY(
          SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
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
          SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE '#{params[:scientific_name]}%'
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
    render :text => Checklist.new(@checklist_params).summarise_filters
  end

  private
  def extract_checklist_params
    @checklist_params = {
      :scientific_name => params[:scientific_name] ? params[:scientific_name] : nil,
      :country_ids => params[:country_ids] ? params[:country_ids] : nil,
      :cites_region_ids =>
        params[:cites_region_ids] ? params[:cites_region_ids] : nil,
      :cites_appendices =>
        params[:cites_appendices] ? params[:cites_appendices] : nil,
      :output_layout =>
        params[:output_layout] ? params[:output_layout].to_sym : nil,
      :common_names =>
        [
          (params[:show_english] == '1' ? 'E' : nil),
          (params[:show_spanish] == '1' ? 'S' : nil),
          (params[:show_french] == '1' ? 'F' : nil)
        ].compact,
      :synonyms => params[:show_synonyms] == '1',
      :level_of_listing => params[:level_of_listing] == '1'
    }
  end

end
