class NomenclatureChange::Lump::TransformationProcessor

  def initialize(output)
    @nc = output.nomenclature_change
    @output = output
  end

  def run
    if @output.taxon_concept.nil?
      process_new_name
    elsif @output.taxon_concept.full_name != @output.display_full_name
      process_name_change
    end
  end

  private

  def process_new_name
    Rails.logger.debug("[#{@nc.type}] [NEW NAME] Processing output #{@output.tmp_taxon_concept.full_name}")
    tc = @output.tmp_taxon_concept
    unless tc.save
      Rails.logger.warn "FAILED to save taxon #{tc.errors.inspect}"
    end
    Rails.logger.debug("UPDATE NEW TAXON ID #{tc.id}")
    @output.update_attributes({:new_taxon_concept_id => tc.id})
  end

  def process_name_change
    Rails.logger.debug("[#{@nc.type}] [NAME CHANGE] Processing output #{@output.tmp_taxon_concept.full_name}")
    tc = @output.tmp_taxon_concept
    unless tc.save
      Rails.logger.warn "FAILED to save taxon #{tc.errors.inspect}"
    end
    #TODO perform status change
    Rails.logger.debug("UPDATE NEW TAXON ID #{tc.id}")
    @output.update_attributes({:new_taxon_concept_id => tc.id})
  end

end
