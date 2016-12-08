class Admin::NomenclatureChanges::LumpController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::Lump::STEPS

  def show
    builder = NomenclatureChange::Lump::Constructor.new(@nomenclature_change)
    case step
    when :inputs
      set_events
      set_taxonomy
      builder.build_inputs
    when :outputs
      set_taxonomy
      set_ranks
      builder.build_output
    when :notes
      builder.build_input_and_output_notes
      builder.build_parent_reassignments
      builder.build_name_reassignments
      builder.build_distribution_reassignments
    when :legislation
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.inputs.map(&:legislation_reassignments).flatten.empty?
    when :summary
      builder.build_document_reassignments
      processor = NomenclatureChange::Lump::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_lump] || {}).merge({
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
    when :outputs
      unless success
        set_taxonomy
        set_ranks
      end
    end
    render_wizard @nomenclature_change
  end

  private

  def klass
    NomenclatureChange::Lump
  end

end
