class Checklist::TaxonConceptItem < Checklist::ChecklistItem
  def initialize(options)
    @item_type = 'TaxonConcept'#TODO class name would do, if as_json would work
    super(options)
  end
end
