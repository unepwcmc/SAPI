class TaxonConceptData

  def initialize(taxon_concept)
    @taxon_concept = taxon_concept.reload
    @rank_name = taxon_concept.rank && taxon_concept.rank.name
    @higher_taxa = higher_taxa
  end

  def to_h
    {
      'rank_name' => @rank_name
    }.merge(@higher_taxa)
  end

  private

  def higher_taxa
    parent_data = higher_taxa_from_parent
    self_data = higher_taxa_from_self
    if parent_data && self_data
      parent_data.merge(self_data)
    elsif self_data
      self_data
    else
      parent_data || {}
    end
  end

  def higher_taxa_from_self
    return nil unless @rank_name
    {
      "#{@rank_name.downcase}_id" => @taxon_concept.id,
      "#{@rank_name.downcase}_name" => @taxon_concept.taxon_name.try(:scientific_name)
    }
  end

  def higher_taxa_from_parent
    field_names = higher_taxa_field_names
    data =
      if @taxon_concept.parent && @taxon_concept.parent.data
        @taxon_concept.parent.data
      else
        fake_parent =
          case @taxon_concept.name_status
          when 'H'
            @taxon_concept.hybrid_parents.first
          when 'S'
            @taxon_concept.accepted_names.first
          when 'T'
            @taxon_concept.accepted_names_for_trade_name.first
          end
        fake_parent && fake_parent.data
      end
    return nil unless data
    data.slice(*field_names)
  end

  def higher_taxa_field_names
    higher_taxa_ranks =
      if @rank_name
        # ranks above this taxon (inclusive of this taxon's rank)
        Rank.in_range(@rank_name, Rank::KINGDOM)
      else
        # all ranks
        Rank.in_range(nil, nil)
      end
    higher_taxa_ranks.map do |r|
      ["#{r.downcase}_id", "#{r.downcase}_name"]
    end.flatten
  end

end
