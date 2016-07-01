module Checklist::ColumnDisplayNameMapping

  ALIASES = {
    :id => 'TaxonId',
    :change_type_name => 'ChangeType',
    :species_listing_name => 'Appendix',
    :hash_full_note_en => '#Annotation',
    :full_hash_ann_symbol => '#AnnotationSymbol',
    :hash_ann_symbol => '#AnnotationSymbol',
    :full_note_en => 'FullAnnotationEnglish',
    :short_note_en => 'AnnotationEnglish',
    :short_note_es => 'AnnotationSpanish',
    :short_note_fr => 'AnnotationFrench',
    :nomenclature_note_en => 'NomenclatureNote',
    :kingdom_name => 'Kingdom',
    :phylum_name => 'Phylum',
    :class_name => 'Class',
    :order_name => 'Order',
    :family_name => 'Family',
    :genus_name => 'Genus',
    :species_name => 'Species',
    :subspecies_name => 'Subspecies',
    :effective_at_formatted => 'EffectiveAt',
    :cites_listing => 'CurrentListing',
    :cites_listing_original => 'CurrentListing',
    :eu_listing => 'CurrentListing',
    :eu_listing_original => 'CurrentListing',
    :cms_listing => 'CurrentListing',
    :cms_listing_original => 'CurrentListing',
    :all_distribution_iso_codes => 'All_DistributionISOCodes',
    :all_distribution => 'All_DistributionFullNames',
    :native_distribution => 'NativeDistributionFullNames',
    :introduced_distribution => 'Introduced_Distribution',
    :introduced_uncertain_distribution => 'Introduced(?)_Distribution',
    :reintroduced_distribution => 'Reintroduced_Distribution',
    :extinct_distribution => 'Extinct_Distribution',
    :extinct_uncertain_distribution => 'Extinct(?)_Distribution',
    :uncertain_distribution => 'Distribution_Uncertain'
  }

  def self.column_display_name_for(column_name)
    ALIASES[column_name] || column_name.to_s.camelize
  end

end
