class Checklist::HigherTaxaItem < Checklist::ChecklistItem
  def initialize(options)
    @item_type = 'HigherTaxa'#TODO class name would do, if as_json would work
    super(options)
    taxa = ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY']
    current_idx = taxa.index(@rank_name) || 0
    @ancestorsPath = 0.upto(current_idx - 1).map do |i|
      taxa[i]
    end.map do |rank|
      send("#{rank.downcase}_name")
    end.join(',')
  end
end