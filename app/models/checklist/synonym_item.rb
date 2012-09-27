class Checklist::SynonymItem < Checklist::ChecklistItem
  attr_reader :synonym_name, :full_name
  def initialize(options)
    @item_type = 'Synonym'
    super(options)
  end
end