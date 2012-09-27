class Checklist::CommonNameItem < Checklist::ChecklistItem
  attr_reader :common_name, :full_name, :lng
  def initialize(options)
    @item_type = 'CommonName'
    super(options)
  end
end