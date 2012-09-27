class Checklist::HigherTaxaItem < Checklist::ChecklistItem
  attr_reader :phylum_name, :class_name, :order_name, :family_name, :rank_name,
    :full_name, :english_names_list, :spanish_names_list, :french_names_list
  def initialize(options)
    @item_type = 'HigherTaxa'#TODO class name would do, if as_json would work
    super(options)
    taxa = ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY']
    current_idx = taxa.index(@rank_name) || 0
    @ancestors_path = 0.upto(current_idx).map do |i|
      taxa[i]
    end.map do |rank|
      send("#{rank.downcase}_name")
    end.join(',')
  end
end