class NomenclatureChange::Split::Processor

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @outputs = nc.outputs
  end

  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @outputs.each_with_index do |output, idx|
      Rails.logger.debug("[#{@nc.type}] Processing output #{output.display_full_name}")
      processor = NomenclatureChange::Split::TransformationProcessor.new(output)
      processor.run
      Rails.logger.debug("[#{@nc.type}] Processing reassignments from #{@input.taxon_concept.full_name}")
      # if input is not one of outputs and this is the last output
      # transfer the associations rather than copy them
      copy = !@outputs.map(&:taxon_concept).include?(input.taxon_concept) && idx = @outputs.length - 1
      processor = NomenclatureChange::ReassignmentProcessor.new(@input, output)
      processor.run
    end
    Rails.logger.warn("[#{@nc.type}] END")
  end

end
