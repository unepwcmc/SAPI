class Checklist::Csv::History < Checklist::History
  include Checklist::Csv::Document
  include Checklist::Csv::HistoryContent

  def taxon_concepts_csv_columns
    [
      :id,
      :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :author_year, :rank_name
    ]
  end

  def listing_changes_csv_columns
    [
      :species_listing_name, :party_iso_code, :party_full_name,
      :change_type_name, :effective_at_formatted, :is_current,
      :hash_ann_symbol, :hash_full_note_en,
      :full_note_en, :short_note_en, :short_note_es, :short_note_fr,
    ]
  end

end
