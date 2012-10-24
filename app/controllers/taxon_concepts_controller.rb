class TaxonConceptsController < ApplicationController
  include ActionController::MimeResponds

  def index
    extract_checklist_params
    @checklist = Checklist::Checklist.new(@checklist_params)
    #render :json => @checklist.generate(params[:page], params[:per_page])
    #render Rabl::Renderer.json(@checklist, 'taxon_concepts/index')
    respond_to :json
  end

  def download_index
    extract_checklist_params
    send_checklist_index_file
  end

  def download_history
    extract_checklist_params
    send_checklist_history_file
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
          SELECT * FROM UNNEST(english_names_ary) name WHERE REGEXP_REPLACE(name, '(.+) (.+)', '\\2, \\1') ILIKE '#{params[:scientific_name]}%'
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
          SELECT * FROM UNNEST(english_names_ary) name WHERE REGEXP_REPLACE(name, '(.+) (.+)', '\\2, \\1') ILIKE '#{params[:scientific_name]}%'
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
    extract_checklist_params

    render :text => Checklist::Checklist.new(@checklist_params).summarise_filters
  end

  private
  def send_checklist_index_file
    ch = if params[:format] == 'pdf'
      Checklist::Pdf::Index.new(@checklist_params)
    elsif params[:format] == 'csv'
      Checklist::Csv::Index.new(@checklist_params)
    elsif params[:format] == 'json'
      Checklist::Json::Index.new(@checklist_params)
    end
    send_checklist_file(ch) unless ch.blank?
  end

  def send_checklist_history_file
    ch = if params[:format] == 'pdf'
      Checklist::Pdf::History.new(@checklist_params)
    elsif params[:format] == 'csv'
      Checklist::Csv::History.new(@checklist_params)
    elsif params[:format] == 'json'
      Checklist::Json::History.new(@checklist_params)
    end
    send_checklist_file(ch) unless ch.blank?
  end

  def send_checklist_file(checklist)
    @download_path = checklist.generate
    send_file(@download_path,
      :filename => checklist.download_name,
      :type => checklist.ext)
    FileUtils.rm @download_path
  end

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
      :authors => params[:show_author] == '1',
      :level_of_listing => params[:level_of_listing] == '1'
    }
  end

end
