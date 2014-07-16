class NomenclatureChange::NameChangeProcessor

  def initialize(output)
    @output = output
  end

  def run
    Rails.logger.debug("[#{@nc.type}] [NAME CHANGE] Processing output #{@output.tmp_taxon_concept.full_name}")
    tc = @output.tmp_taxon_concept
    unless tc.save
      Rails.logger.warn "FAILED to save taxon #{tc.errors.inspect}"
      return false
    end
    # if @output.taxon_concept.name_status == 'A'
    #   # process status change A -> S for old name
    #   NomenclatureChange::StatusChange.create(
    #     input_attributes: {
    #       taxon_concept_id: @output.taxon_concept_id
    #     },
    #     primary_output_attributes: {
    #       taxon_concept_id: @output.taxon_concept_id,
    #       new_name_status: 'S'
    #     },
    #     secondary_output_attributes: {
    #       taxon_concept_id: tc.id
    #     },
    #     status: NomenclatureChange::SUBMITTED
    #   )
    # end
    Rails.logger.debug("UPDATE NEW TAXON ID #{tc.id}")
    @output.update_attributes({new_taxon_concept_id: tc.id})
  end

end
