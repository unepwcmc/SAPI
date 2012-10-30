class Checklist::Index < Checklist::Checklist
  attr_reader :download_name

  def initialize(options={})
    @download_path = download_location(options, "index", @ext)

    if !File.exists?(@download_path)
      super(options.merge({:output_layout => :alphabetical}))
    end

    @download_name = "FullChecklist-#{Time.now}.#{@ext}"
  end

  def taxon_concepts_columns
    super +
    [:generic_annotation_parent_symbol] -
    [:specific_annotation_symbol]
  end

  def listing_changes_columns
    super - [
      :generic_english_full_note, :english_full_note, :english_short_note,
      :generic_spanish_full_note, :spanish_full_note, :spanish_short_note,
      :generic_french_full_note, :french_full_note, :french_short_note
    ]
  end

  def prepare_main_query
    @taxon_concepts_rel = @taxon_concepts_rel.without_nc.without_hidden
  end

  def prepare_kingdom_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_position = 0")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_position = 1")
  end

  def generate
    return @download_path  if File.exists?(@download_path)

    prepare_queries
    document do |doc|
      content(doc)
    end
    finalize
    @download_path
  end

  def finalize; end

  def columns
    res = super + [
      :phylum_name, :class_name, :order_name, :family_name,
      :cites_accepted, :current_listing,
      :generic_annotation_full_symbol,
      :english_names, :spanish_names, :french_names, :synonyms
    ]
    res -= [:synonyms] unless @synonyms
    res -= [:english_names] unless @english_common_names
    res -= [:spanish_names] unless @spanish_common_names
    res -= [:french_names] unless @french_common_names
    res
  end

  def column_value_for_generic_annotation_full_symbol(rec)
    "#{rec.generic_annotation_symbol} #{rec.generic_annotation_parent_symbol}"
  end

end
