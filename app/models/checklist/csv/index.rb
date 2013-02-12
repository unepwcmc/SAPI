class Checklist::Csv::Index < Checklist::Index
  include Checklist::Csv::Document
  include Checklist::Csv::IndexContent

  def taxon_concepts_csv_columns
    all_json_options = taxon_concepts_json_options
    res = all_json_options[:only] + all_json_options[:methods]
    res -= [:ancestors_path, :ann_symbol, :countries_ids]
    res += [:countries_iso_codes, :countries_full_names]
    case I18n.locale
    when :es
      res +=
        [:hash_full_note_es, :full_note_es]
    when:fr
      res +=
        [:hash_full_note_fr, :full_note_fr]
    else
      res +=
        [:hash_full_note_en, :full_note_en]
    end
    res
  end

  def listing_changes_csv_columns
    []
  end

  def prepare_main_query
    super()
    @taxon_concepts_rel = @taxon_concepts_rel.
      includes(:current_listing_changes)
  end

end
