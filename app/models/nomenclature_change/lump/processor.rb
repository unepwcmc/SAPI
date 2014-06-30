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
    end
    Rails.logger.warn("[#{@nc.type}] END")
  end

end
