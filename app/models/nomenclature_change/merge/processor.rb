class NomenclatureChange::Merge::Processor

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @outputs = nc.outputs
  end

  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @outputs.each do |output|
      Rails.logger.debug("[#{@nc.type}] Processing output #{output.display_full_name}")
      processor = NomenclatureChange::Merge::TransformationProcessor.new(output)
      processor.run
      Rails.logger.debug("[#{@nc.type}] Processing reassignments from #{@input.taxon_concept.full_name}")
      processor = NomenclatureChange::Merge::ReassignmentProcessor.new(@input, output)
      processor.run
    end
    Rails.logger.warn("[#{@nc.type}] END")
  end

end
