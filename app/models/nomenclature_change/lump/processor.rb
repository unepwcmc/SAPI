class NomenclatureChange::Lump::Processor

  def initialize(nc)
    @nc = nc
    @inputs = nc.inputs
    @output = nc.output
  end

  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    Rails.logger.debug("[#{@nc.type}] Processing output #{@output.display_full_name}")
    processor = NomenclatureChange::Lump::TransformationProcessor.new(@output)
    processor.run
    @inputs.each do |input|
      Rails.logger.debug("[#{@nc.type}] Processing reassignments from #{input.taxon_concept.full_name}")
      processor = NomenclatureChange::Lump::ReassignmentProcessor.new(input, @output)
      processor.run
      input.reassignments.each do |reassignment|
        unless @output.taxon_concept == input.taxon_concept || reassignment.kind_of?(NomenclatureChange::ParentReassignment)
          # input is not part of the split
          # delete original association
          Rails.logger.warn("Deleting #{reassignment.reassignable_type} (id=#{reassignment.reassignable_id}) from #{input.taxon_concept.full_name}")
          if reassignment.reassignable_id.blank?
            reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
              reassignable.destroy
            end
          else
            reassignment.reassignable.destroy
          end
        end
      end
    end
    Rails.logger.warn("[#{@nc.type}] END")
  end

end
