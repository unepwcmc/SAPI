class Admin::NomenclatureChanges::StatusChangeController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::StatusChange::STEPS

  def show
    builder = NomenclatureChange::StatusChange::Constructor.new(@nomenclature_change)
    case step
    when :primary_output
      set_events
      set_taxonomy
      builder.build_primary_output
    when :relay_or_swap
      skip_or_previous_step unless @nomenclature_change.needs_to_relay_associations?
      set_taxonomy
      builder.build_secondary_output
    when :receive_or_swap
      skip_or_previous_step unless @nomenclature_change.needs_to_receive_associations?
      set_taxonomy
      builder.build_secondary_output
      builder.build_input
    when :notes
      builder.build_output_notes
    when :legislation
      skip_or_previous_step unless @nomenclature_change.is_swap?
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.input.nil? || @nomenclature_change.input.legislation_reassignments.empty?
    when :summary
      processor = NomenclatureChange::StatusChange::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    # the following handles 2 ways in which user might have filled in the form
    if step == :relay_or_swap
      which_secondary_output =
        params.delete(:secondary_output) || 'secondary_output_1'
      params[:nomenclature_change_status_change][:secondary_output_attributes] =
        params[:nomenclature_change_status_change][which_secondary_output]
      params[:nomenclature_change_status_change].delete(:secondary_output_1)
      params[:nomenclature_change_status_change].delete(:secondary_output_2)
    elsif step == :receive_or_swap
      if params.delete(:secondary_output) == 'input'
        params[:nomenclature_change_status_change].delete(:secondary_output_attributes)
      else
        params[:nomenclature_change_status_change].delete(:input_attributes)
      end
    end
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_status_change] || {}).merge({
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
    when :relay_or_swap, :receive_or_swap
      set_taxonomy unless success
    end
    render_wizard @nomenclature_change
  end

  private
  def klass
    NomenclatureChange::StatusChange
  end

end
