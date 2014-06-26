class NomenclatureChange::Split::TransformationSummarizer

  delegate :new_rank, :to => :"@output"
  delegate :new_parent, :to => :"@output"
  delegate :new_full_name, :to => :"@output"
  delegate :new_author_year, :to => :"@output"
  delegate :new_name_status, :to => :"@output"
  delegate :display_full_name, :to => :"@output"
  delegate :taxon_concept, :to => :"@output"

  def initialize(output)
    @output = output
  end

  def summary
    res = []
    rank_name = new_rank.try(:name) || taxon_concept.try(:rank).try(:name)
    full_name = display_full_name
    name_status = new_name_status || taxon_concept.try(:name_status)
    if taxon_concept.blank?
      res << "New #{rank_name} #{full_name} (#{name_status}) will be created"
    elsif new_full_name && taxon_concept.full_name != new_full_name
      res << "New #{rank_name} #{full_name} (#{name_status}) will be created, based on #{taxon_concept.full_name}"
      if ['A', 'N', 'H'].include? taxon_concept.name_status
        res << "#{taxon_concept.full_name} will be turned into a synonym of #{display_full_name}"
      end
    else
      if new_rank
        res << "#{taxon_concept.full_name} rank changed from #{taxon_concept.rank.name} to #{new_rank.name}"
      end
      if new_parent
        res << "#{taxon_concept.full_name} parent changed from #{taxon_concept.parent.full_name} to #{new_parent.full_name}"
      end
      if new_name_status
        res << "#{taxon_concept.full_name} name status changed from #{taxon_concept.name_status} to #{new_name_status}"
      end
      if new_author_year
        res << "#{taxon_concept.full_name} author year changed from #{taxon_concept.author_year} to #{new_author_year}"
      end
    end
    res
  end

end
