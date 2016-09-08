class Admin::NomenclatureChanges::StatusSwapController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::StatusSwap::STEPS

  def show
    builder = klass::Constructor.new(@nomenclature_change)
    case step
    when :primary_output
      set_events
      set_taxonomy
      builder.build_primary_output
    when :secondary_output
      set_taxonomy
      set_ranks
      builder.build_secondary_output
    when :notes
      builder.build_secondary_output_note
    when :legislation
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.input.legislation_reassignments.empty?
    when :summary
      processor = klass::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_status_swap] || {}).merge({
        :status => (step == steps.last ? NomenclatureChange::SUBMITTED : step.to_s)
      })
    )
    success = @nomenclature_change.valid?
    case step
    when :primary_output
      unless success
        set_events
        set_taxonomy
      end
    when :secondary_output
      unless success
        set_taxonomy
        set_ranks
      end
    end
    render_wizard @nomenclature_change
  end

  private

  def klass
    NomenclatureChange::StatusSwap
  end

end
