class NomenclatureChange::Lump::Summarizer

  def initialize(lump)
    @lump = lump
  end

  def summary
    res = [
      "#{@lump.inputs.map{|i| i.taxon_concept.full_name}.join(", ")} will be lumped into:",
      (
        output = @lump.output
        res = [output.display_full_name]
        transformations = NomenclatureChange::Lump::TransformationSummarizer.new(output).summary
        unless transformations.empty?
          res << [
            "The following transformations will be performed:",
            transformations
          ]
        end
        @lump.inputs.each do |input|
          reassignments = NomenclatureChange::Lump::ReassignmentSummarizer.new(input, output).summary
          unless reassignments.empty?
            res << [
              "The following reassignments from #{input.taxon_concept.full_name} will be performed:",
              reassignments
            ]
          end
        end
        res
      )
    ]
  end

end
