class NomenclatureChange::StatusChange::TransformationProcessor

  def initialize(output)
    @nc = output.nomenclature_change
    @output = output
  end

  def run
    tc = @output.tmp_taxon_concept
    unless tc.save
      Rails.logger.warn "FAILED to save taxon #{tc.errors.inspect}"
      return false
    end
  end

end
