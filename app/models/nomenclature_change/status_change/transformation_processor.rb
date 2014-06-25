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
    # I think this goes into nomenclature change processor really
    if @nc.needs_to_relay_associations?
      # mark old accepted name (primary output) as synonym
      # of new accepted name (secondary output)
      @nc.primary_output.taxon_relationships.each do |tr|
        tr.taxon_concept_id = @nc.secondary_output.taxon_concept_id
      end
    elsif @nc.needs_to_receive_associations? && @nc.is_swap?
      @nc.primary_output.inverse_taxon_relationships.each do |tr|
        tr.other_taxon_concept_id = @nc.secondary_output.taxon_concept_id
      end
    end
  end

end
