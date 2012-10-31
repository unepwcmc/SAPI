require 'csv'
module Checklist::Csv::Document

  def ext
    'csv'
  end

  def document
    CSV.open(@download_path, "wb") do |csv|
      yield csv
    end

    @download_path
  end

  def column_headers
    (taxon_concepts_csv_columns + listing_changes_csv_columns).map do |c|
      column_export_name(c)
    end
  end

  def column_export_name(col)
    aliases = {
      :change_type_name => 'ChangeType',
      :species_listing_name => 'Appendix',
      :generic_english_full_note => '#AnnotationEnglish',
      :generic_spanish_full_note => '#AnnotationSpanish',
      :generic_french_full_note => '#AnnotationFrench',
      :english_full_note => 'AnnotationEnglish',
      :spanish_full_note => 'AnnotationSpanish',
      :french_full_note => 'AnnotationFrench'
    }
    aliases[col] || col.to_s.camelize
  end

end
