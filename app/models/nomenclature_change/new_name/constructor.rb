class NomenclatureChange::NewName::Constructor
  include NomenclatureChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
  end

  def build_output
    @nomenclature_change.build_output if @nomenclature_change.output.nil?
  end

  def multi_lingual_output_note(output, event)
    result = {}
    [:en, :es, :fr].each do |lng|
      note = '<p>'
      note << new_name_note(output, lng)
      note << following_taxonomic_changes(event, lng) if event
      note << '.</p>'
      result[lng] = note
    end
    result
  end

  def build_output_notes
    output = @nomenclature_change.output
    event = @nomenclature_change.event
    if output.note_en.blank?
      note = multi_lingual_output_note(output, event)
      output.note_en = note[:en]
      output.note_es = note[:es]
      output.note_fr = note[:fr]
    end
  end

  def new_name_note(output, lng)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    I18n.with_locale(lng) do
      I18n.translate(
        'new_name.new_name_note',
        output_taxon: output_html,
        year: Date.current.year,
        default: 'Translation missing'
      )
    end
  end
end
