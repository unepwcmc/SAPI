class Checklist::HigherTaxaItem < Checklist::ChecklistItem
  def initialize(options)
    @item_type = 'HigherTaxa'#TODO class name would do, if as_json would work
    super(options)
  end
end