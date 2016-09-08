class NomenclatureChange::InputTaxonConceptProcessor

  def initialize(input)
    @input = input
  end

  def run
    return false unless @input.taxon_concept
    Rails.logger.debug("Processing input #{@input.taxon_concept.full_name}")
    tc = @input.taxon_concept
    tc.update_attributes(
      nomenclature_note_en: "#{tc.nomenclature_note_en} #{@input.note_en}",
      nomenclature_note_es: "#{tc.nomenclature_note_es} #{@input.note_es}",
      nomenclature_note_fr: "#{tc.nomenclature_note_fr} #{@input.note_fr}"
    )
    nomenclature_comment = tc.nomenclature_comment || tc.create_nomenclature_comment
    nomenclature_comment.update_attribute(
      :note,
      "#{nomenclature_comment.note} #{@input.internal_note}"
    )
  end

  def summary
    ["Will add nomenclature note for input #{@input.taxon_concept.full_name}"]
  end
end
