class Admin::NomenclatureChanges::SplitController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::Split::STEPS

  def show
    builder = NomenclatureChange::Split::Constructor.new(@nomenclature_change)
    case step
    when :inputs
      set_events
      set_taxonomy
      builder.build_input
    when :outputs
      set_taxonomy
      set_ranks
      builder.build_outputs
    when :notes
      builder.build_input_and_output_notes
    when :children
      builder.build_parent_reassignments
      skip_or_previous_step if @nomenclature_change.input.parent_reassignments.empty?
    when :names
      builder.build_name_reassignments
      skip_or_previous_step if @nomenclature_change.input.name_reassignments.empty?
    when :distribution
      builder.build_distribution_reassignments
      skip_or_previous_step if @nomenclature_change.input.distribution_reassignments.empty?
    when :legislation
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.input.legislation_reassignments.empty?
    when :summary
      builder.build_document_reassignments
      processor = NomenclatureChange::Split::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_split] || {}).merge({
        :status => (step == steps.last ? NomenclatureChange::SUBMITTED : step.to_s)
      })
    )
    success = @nomenclature_change.valid?
    case step
    when :inputs, :outputs
      unless success
        set_events
        set_taxonomy
        set_ranks
      end
    end
    render_wizard @nomenclature_change
  end

  private

  def klass
    NomenclatureChange::Split
  end

end
