class Checklist::HigherTaxaItem
  include ActiveModel::SerializerSupport

  def initialize(taxon_concept)
    @taxon_concept = taxon_concept
  end

  def ancestors_ranks
    taxa =
      if kingdom_name == 'Plantae'
        ['FAMILY', 'SUBFAMILY']
      else
        ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY', 'SUBFAMILY']
      end
    current_idx = taxa.index(rank_name) || 0
    0.upto(current_idx).map do |i|
      taxa[i]
    end
  end

  def ancestors_path
    ancestors_ranks.map do |rank|
      send("#{rank.downcase}_name")
    end.join(',')
  end

  def ancestors_ids
    ancestors_ranks.map do |rank|
      send("#{rank.downcase}_id")
    end.join(',')
  end

  # use method_missing to delegate taxon concept methods
  def method_missing(method_sym, *arguments, &block)
    # the first argument is a Symbol, so you need to_s it if you want to pattern match
    if @taxon_concept.respond_to? method_sym
      @taxon_concept.send(method_sym)
    else
      super
    end
  end

  def as_json(options = {})
    {
      :id => id + 100000,
      :item_type => @item_type,
      :rank_name => rank_name,
      :ancestors_path => ancestors_path,
      :ancestors_ids => ancestors_ids
    }
  end

end
