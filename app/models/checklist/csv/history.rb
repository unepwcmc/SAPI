class Checklist::Csv::History < Checklist::History
  include Checklist::Csv::Document
  include Checklist::Csv::HistoryContent

  def taxon_concepts_csv_columns
    all_json_options = taxon_concepts_json_options
    all_json_options[:only] + all_json_options[:methods]
  end

  def listing_changes_csv_columns
    all_json_options = listing_changes_json_options
    res = all_json_options[:only] + all_json_options[:methods]
    split = res.index(:party_name)
    res = res[0..split] + [:party_full_name] + res[split+1..res.length-1]
    split = res.index(:countries_iso_codes)
    res = res[0..split] + [:countries_full_names] +
      res[split+1..res.length-1]
    res
  end

end
