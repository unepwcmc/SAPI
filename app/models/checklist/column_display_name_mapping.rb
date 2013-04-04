module Checklist::ColumnDisplayNameMapping

  ALIASES = {
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
    :countries_full_names => 'DistributionFullNames',
    :current_listing_original => 'CurrentListing'
  }

  def self.column_display_name_for(column_name)
    ALIASES[column_name] || column_name.to_s.camelize
  end

end