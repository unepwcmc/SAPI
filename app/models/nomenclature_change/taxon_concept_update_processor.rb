class NomenclatureChange::TaxonConceptUpdateProcessor

  def initialize(output)
    @output = output
  end

  def run
    return false unless @output.tmp_taxon_concept
    Rails.logger.debug("Processing output #{@output.tmp_taxon_concept.full_name}")
    tc = @output.tmp_taxon_concept
    new_record = tc.new_record?
    unless tc.save
      Rails.logger.warn "FAILED to save taxon #{tc.errors.inspect}"
      return false
    end
    if new_record
      Rails.logger.debug("UPDATE NEW TAXON ID #{tc.id}")
      @output.update_column(:new_taxon_concept_id, tc.id)
    end
  end

  def summary
    res = []
    rank_name = @output.new_rank.try(:name) || @output.taxon_concept.try(:rank).try(:name)
    full_name = @output.display_full_name
    name_status = @output.new_name_status || @output.taxon_concept.try(:name_status)
    if @output.taxon_concept.blank?
      res << "New #{rank_name} #{full_name} (#{name_status}) will be created"
    elsif @output.new_full_name && @output.taxon_concept.full_name != @output.new_full_name
      res << "New #{rank_name} #{full_name} (#{name_status}) will be created, based on #{@output.taxon_concept.full_name}"
      if ['A', 'N', 'H'].include? @output.taxon_concept.name_status
        res << "#{@output.taxon_concept.full_name} will be turned into a synonym of #{@output.display_full_name}"
      end
    else
      if @output.new_rank
        res << "#{@output.taxon_concept.full_name} rank changed from #{@output.taxon_concept.rank.name} to #{@output.new_rank.name}"
      end
      if @output.new_parent
        res << "#{@output.taxon_concept.full_name} parent changed from #{@output.taxon_concept.parent.full_name} to #{@output.new_parent.full_name}"
      end
      if @output.new_name_status
        res << "#{@output.taxon_concept.full_name} name status changed from #{@output.taxon_concept.name_status} to #{@output.new_name_status}"
      end
      if @output.new_author_year
        res << "#{@output.taxon_concept.full_name} author year changed from #{@output.taxon_concept.author_year} to #{@output.new_author_year}"
      end
    end
    res
  end

end
