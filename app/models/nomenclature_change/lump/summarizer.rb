class NomenclatureChange::Lump::Summarizer

  def initialize(lump)
    @lump = lump
  end

  def summary
    res = [
      "#{@lump.input.taxon_concept.full_name} will be lump into:",
      @lump.outputs.map do |output|
        res = [output.display_full_name]
        transformations = NomenclatureChange::Lump::TransformationSummarizer.new(output).summary
        unless transformations.empty?
          res << [
            "The following transformations will be performed:",
            transformations
          ]
        end
        reassignments = NomenclatureChange::Lump::ReassignmentSummarizer.new(@lump.input, output).summary
        unless reassignments.empty?
          res << [
            "The following reassignments from #{@lump.input.taxon_concept.full_name} will be performed:",
            reassignments
          ]
        end
        res
      end
    ]
  end

end
