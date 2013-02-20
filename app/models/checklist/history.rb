class Checklist::History < Checklist::Checklist
  attr_reader :download_name

  def initialize(options={})
    @download_path = download_location(options, "history", ext)

    if !File.exists?(@download_path)
      super(options.merge({:output_layout => :taxonomic}))
    end

    @download_name = "ChecklistHistory-#{Time.now}.#{ext}"
  end

  def prepare_kingdom_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_position = 0")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_position = 1")
  end

  def prepare_main_query
    @taxon_concepts_rel = @taxon_concepts_rel.
      includes(:listing_changes).
      where("cites_listed = 't'").
      where("listing_changes_mview.change_type_name <> 'EXCEPTION'").
      where("NOT (listing_changes_mview.change_type_name = 'DELETION' " +
        "AND listing_changes_mview.species_listing_name IS NOT NULL " +
        "AND listing_changes_mview.party_name IS NULL)"
      ).order <<-SQL
      taxon_concept_id, effective_at,
      CASE
        WHEN change_type_name = 'ADDITION' THEN 0
        WHEN change_type_name = 'RESERVATION' THEN 1
        WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 2
        WHEN change_type_name = 'DELETION' THEN 3
      END
      SQL
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
