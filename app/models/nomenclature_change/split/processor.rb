class NomenclatureChange::Split::Processor

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @outputs = nc.outputs
  end

  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @outputs.each do |output|
      Rails.logger.debug("[#{@nc.type}] Processing output #{output.display_full_name}")
      processor = NomenclatureChange::Split::TransformationProcessor.new(output)
      processor.run
      Rails.logger.debug("[#{@nc.type}] Processing reassignments from #{@input.taxon_concept.full_name}")
      processor = NomenclatureChange::ReassignmentProcessor.new(@input, output)
      processor.run
    end
    unless @outputs.map(&:taxon_concept).include?(@input.taxon_concept)
      @input.reassignments.each do |reassignment|
        unless reassignment.kind_of?(NomenclatureChange::ParentReassignment) # don't delete taxa
          # input is not part of the split
          # delete original association
          Rails.logger.warn("Deleting #{reassignment.reassignable_type} (id=#{reassignment.reassignable_id}) from #{@input.taxon_concept.full_name}")
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
