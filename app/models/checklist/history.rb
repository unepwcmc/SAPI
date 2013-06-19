class Checklist::History < Checklist::Checklist
  attr_reader :download_name

  def initialize(options={})
    options = {
      :output_layout => :taxononomic,
      :show_english => true,
      :show_french => true,
      :show_spanish => true
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

    @download_name = "ChecklistHistory-#{Time.now.strftime("%d%m%Y")}.#{ext}"
  end

  def prepare_kingdom_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_position = 0")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_position = 1")
  end

  def prepare_main_query
    @taxon_concepts_rel = MTaxonConcept.
       includes(:listing_changes).
        where(<<-SQL
          listing_changes_mview.change_type_name != 'EXCEPTION'
            AND listing_changes_mview.explicit_change = TRUE
            AND listing_changes_mview.designation_name = '#{Designation::CITES}'
          SQL
        ).
        order(<<-SQL
          taxonomic_position, effective_at,
          CASE
            WHEN change_type_name = 'ADDITION' THEN 0
            WHEN change_type_name = 'RESERVATION' THEN 1
            WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 2
            WHEN change_type_name = 'DELETION' THEN 3
          END
          SQL
        )
  end

  def generate
    return @download_path  if File.exists?(@download_path)

    prepare_queries
    document do |doc|
      content(doc)
    end
    @download_path
  end

  def taxon_concepts_json_options
    json_options = super
    #less taxon information for the history
    json_options[:only] -= [:hash_ann_symbol]
    json_options[:only] -= [
      :current_listing, :cites_accepted, :ann_symbol,
      :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name
    ]
    json_options[:methods] -= [:recently_changed, :countries_ids,
      :english_names, :spanish_names, :french_names, :synonyms,
      :ancestors_path]
    json_options
  end

  def listing_changes_json_options
    json_options = super
    json_options[:only] -= [:symbol]
    json_options[:only] += [:short_note_fr, :short_note_es]
    json_options[:methods] -= [:countries_ids]
    json_options[:methods] += [:countries_iso_codes, :full_hash_ann_symbol]
    json_options
  end

  def json_options
    json_options = taxon_concepts_json_options
    json_options[:include] = {
      :listing_changes => listing_changes_json_options
    }
    json_options
  end

end
