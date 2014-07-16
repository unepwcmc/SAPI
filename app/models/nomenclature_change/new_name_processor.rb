class NomenclatureChange::NewNameProcessor

  def initialize(output)
    @output = output
  end

  def run
    Rails.logger.debug("[#{@nc.type}] [NEW NAME] Processing output #{@output.tmp_taxon_concept.full_name}")
    tc = @output.tmp_taxon_concept
    unless tc.save
      Rails.logger.warn "FAILED to save taxon #{tc.errors.inspect}"
      return false
    end
    Rails.logger.debug("UPDATE NEW TAXON ID #{tc.id}")
    @output.update_attributes({new_taxon_concept_id: tc.id})
  end

end
