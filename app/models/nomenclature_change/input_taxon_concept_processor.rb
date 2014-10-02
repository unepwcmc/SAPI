class NomenclatureChange::InputTaxonConceptProcessor

  def initialize(input)
    @input = input
  end

  def run
    return false unless @input.taxon_concept
    Rails.logger.debug("Processing input #{@input.taxon_concept.full_name}")
    @input.taxon_concept.update_attributes(
      nomenclature_note_en: "#{@input.taxon_concept.nomenclature_note_en} #{@input.note_en}",
      nomenclature_note_es: "#{@input.taxon_concept.nomenclature_note_es} #{@input.note_es}",
      nomenclature_note_fr: "#{@input.taxon_concept.nomenclature_note_fr} #{@input.note_fr}",
      internal_nomenclature_note: "#{@input.taxon_concept.internal_nomenclature_note} #{@input.internal_note}"
    )
  end

  def summary
    ["Will add nomenclature note for input #{@input.taxon_concept.full_name}"]
  end
end