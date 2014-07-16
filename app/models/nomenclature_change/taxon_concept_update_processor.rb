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

end
