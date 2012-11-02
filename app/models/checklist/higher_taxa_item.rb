class Checklist::HigherTaxaItem
  attr_reader :rank_name, :full_name, :english_names, :spanish_names, :french_names

  def initialize(taxon_concept)
    @item_type = 'HigherTaxa'#TODO class name would do, if as_json would work
    @taxon_concept = taxon_concept
    [
      :rank_name, :full_name, :english_names, :spanish_names, :french_names
    ].each do |attribute|
    instance_variable_set("@#{attribute}", @taxon_concept.send(attribute))
  end
    taxa = ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY']
    current_idx = taxa.index(@rank_name) || 0
    @ancestors_path = 0.upto(current_idx).map do |i|
      taxa[i]
    end.map do |rank|
      taxon_concept.send("#{rank.downcase}_name")
    end.join(',')
  end

end