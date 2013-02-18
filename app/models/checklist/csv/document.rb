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
      :id => 'TaxonId',
      :change_type_name => 'ChangeType',
      :species_listing_name => 'Appendix',
      :change_type_name => 'ChangeType',
      :hash_full_note_en => '#Annotation',
      :full_hash_ann_symbol => '#AnnotationSymbol',
      :hash_ann_symbol => '#AnnotationSymbol',
      :full_note_en => 'FullAnnotationEnglish',
      :short_note_en => 'AnnotationEnglish',
      :short_note_es => 'AnnotationSpanish',
      :short_note_fr => 'AnnotationFrench',
      :kingdom_name => 'Kingdom',
      :phylum_name => 'Phylum',
      :class_name => 'Class',
      :order_name => 'Order',
      :family_name => 'Family',
      :genus_name => 'Genus',
      :species_name => 'Species',
      :subspecies_name => 'Subspecies',
      :effective_at_formatted => 'EffectiveAt',
      :countries_iso_codes => 'DistributionISOCodes',
      :countries_full_names => 'DistributionFullNames'
    }
    aliases[col] || col.to_s.camelize
  end

end
