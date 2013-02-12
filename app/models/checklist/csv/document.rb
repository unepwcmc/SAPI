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
      :hash_full_note_en => '#AnnotationEnglish',
      :hash_full_note_es => '#AnnotationSpanish',
      :hash_full_note_fr => '#AnnotationFrench',
      :full_note_en => 'AnnotationEnglish',
      :full_note_es => 'AnnotationSpanish',
      :full_note_fr => 'AnnotationFrench'
    }
    aliases[col] || col.to_s.camelize
  end

end
