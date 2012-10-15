#paste into rails console to get both generic + specific annotation for Panax ginseng
tc = TaxonConcept.where("data->'full_name' = 'Panax ginseng'").first
lc1 = tc.listing_changes.where(:effective_at => '2000-07-19').first
lc2 = tc.listing_changes.where(:effective_at => '2007-09-13').first

english = Language.find_by_name('English')
spanish = Language.find_by_name('Spanish')
french = Language.find_by_name('French')

russia = GeoEntity.find_by_iso_code2('Ru')

#add listing distribution
ListingDistribution.create(
  :listing_change_id => lc1.id,
  :geo_entity_id => russia.id,
  :is_party => false
)
ListingDistribution.create(
  :listing_change_id => lc2.id,
  :geo_entity_id => russia.id,
  :is_party => false
)

#update specific annotation to only include specific part with html
a1 = Annotation.find_or_create_by_listing_change_id(lc1.id)
at = AnnotationTranslation.find_by_annotation_id(a1.id)
at.full_note = "Population of RU"
at.save

#add other translations of the specific annotation
AnnotationTranslation.create(
  :annotation_id => a1.id,
  :language_id => spanish.id,
  :full_note =>"Población de RU"
)

AnnotationTranslation.create(
  :annotation_id => a1.id,
  :language_id => french.id,
  :full_note =>"Population de RU"
)

a2 = Annotation.find_or_create_by_listing_change_id(lc2.id)
at = AnnotationTranslation.find_by_annotation_id(a2.id)
at.full_note = "Population of RU"
at.save

#add other translations of the specific annotation
AnnotationTranslation.create(
  :annotation_id => a2.id,
  :language_id => spanish.id,
  :full_note =>"Población de RU"
)

AnnotationTranslation.create(
  :annotation_id => a2.id,
  :language_id => french.id,
  :full_note =>"Population de RU"
)

#add generic annotation with html
a1 = Annotation.create(:symbol => '#3', :parent_symbol => 'CoP11')
lc1.annotation_id = a1.id
lc1.save
a2 = Annotation.create(:symbol => '#3', :parent_symbol => 'CoP14')
lc2.annotation_id = a2.id
lc2.save

AnnotationTranslation.create(
  :annotation_id => a1.id,
  :language_id => english.id,
  :full_note => <<-END
Designates whole and sliced roots and parts of roots, excluding manufactured parts or derivatives such as
powders, pills, extracts, tonics, teas and confectionery
END
)
AnnotationTranslation.create(
  :annotation_id => a2.id,
  :language_id => english.id,
  :full_note => <<-END
Whole and sliced roots and parts of roots
END
)