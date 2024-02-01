class Checklist::Csv::Index < Checklist::Index
  include Checklist::Csv::Document
  include Checklist::Csv::IndexContent

  def taxon_concepts_csv_columns
    [
      :id,
      :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :author_year, :rank_name, :cites_listing,
      :full_note_en, :short_note_en, :short_note_es, :short_note_fr,
      :hash_ann_symbol, :hash_full_note_en,
      if @synonyms && @authors
        :synonyms_with_authors
      elsif @synonyms
        :synonyms
      end,
      if @english_common_names then :english_names end,
      if @spanish_common_names then :spanish_names end,
      if @french_common_names then :french_names end,
      :cites_accepted,
      :all_distribution_iso_codes, :all_distribution,
      :native_distribution, :introduced_distribution,
      :introduced_uncertain_distribution, :reintroduced_distribution,
      :extinct_distribution, :extinct_uncertain_distribution,
      :uncertain_distribution
    ].compact
  end

  def listing_changes_csv_columns
    []
  end

  def prepare_main_query
    super()
    @taxon_concepts_rel = @taxon_concepts_rel.
      includes(:current_cites_additions)
  end

end
