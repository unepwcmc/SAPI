class Checklist::History < Checklist::Checklist
  attr_reader :download_name

  def initialize(options = {})
    options = {
      :output_layout => :taxonomic,
      :show_english => true,
      :show_french => true,
      :show_spanish => true,
      :intro => true
    }
    # History cannot be parametrized like other Checklist reports
    @download_path = download_location(options, "history", ext)

    # If a cached download exists, only initialize the params for the
    # helper methods, otherwise initialize the generation queries.

    if !File.exists?(@download_path)
      super(options)
    else
      initialize_params(options)
    end
  end

  def has_full_options?
    true
  end

  def prepare_kingdom_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_position = 0")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_position = 1")
  end

  def prepare_main_query
    @taxon_concepts_rel = MTaxonConcept.where(:taxonomy_is_cites_eu => true).
      where(
        <<-SQL
        EXISTS (
          SELECT * FROM cites_listing_changes_mview
          WHERE taxon_concept_id = taxon_concepts_mview.id
          AND show_in_downloads
        )
        SQL
      ).
      order(:taxonomic_position)
  end

  def generate
    if !File.exists?(@download_path)
      prepare_queries
      document do |doc|
        content(doc)
      end
    end
    ctime = File.ctime(@download_path).strftime('%Y-%m-%d %H:%M')
    doc_name = I18n.t('history_title').split.join('_')
    @download_name = "#{doc_name}_#{has_full_options? ? '' : '[CUSTOM]_'}#{ctime}.#{ext}"
    @download_path
  end

end
