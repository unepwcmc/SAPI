class Checklist::Csv::Index < Checklist::Index
  include Checklist::Csv::Document
  include Checklist::Csv::IndexContent

  def taxon_concepts_csv_columns
    all_json_options = taxon_concepts_json_options
    res = all_json_options[:only] + all_json_options[:methods]
    res -= [:ancestors_path, :specific_annotation_symbol, :countries_ids]
    res += [:countries_iso_codes, :countries_full_names]
    case I18n.locale
    when :es
      res +=
        [:generic_spanish_full_note, :spanish_full_note]
    when:fr
      res +=
        [:generic_french_full_note, :french_full_note]
    else
      res +=
        [:generic_english_full_note, :english_full_note]
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
