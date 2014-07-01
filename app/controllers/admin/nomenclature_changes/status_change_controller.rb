class Admin::NomenclatureChanges::StatusChangeController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::StatusChange::STEPS

  def create
    @nomenclature_change = NomenclatureChange::StatusChange.new(:status => NomenclatureChange::NEW)
    if @nomenclature_change.save
      redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
    else
      redirect_to admin_nomenclature_changes_url, :alert => "Could not start a new nomenclature change"
    end
  end

  def show
    builder = NomenclatureChange::StatusChange::Constructor.new(@nomenclature_change)
    case step
    when :primary_output
      set_events
      builder.build_primary_output
    when :relay_or_swap
      skip_step unless @nomenclature_change.needs_to_relay_associations?
      builder.build_secondary_output
    when :receive_or_swap
      skip_step unless @nomenclature_change.needs_to_receive_associations?
      builder.build_secondary_output
      builder.build_input
    when :notes
      builder.build_output_notes
    when :legislation
      skip_step unless @nomenclature_change.is_swap?
      builder.build_reassignments
      skip_step if @nomenclature_change.input.legislation_reassignments.empty?
    when :summary
      @summary = NomenclatureChange::StatusChange::Summarizer.new(@nomenclature_change).summary
    end
    render_wizard
  end

  def update
    if step == :relay_or_swap
      which_secondary_output =
        params.delete(:secondary_output) || 'secondary_output_1'
      params[:nomenclature_change_status_change][:secondary_output_attributes] =
        params[:nomenclature_change_status_change][which_secondary_output]
      params[:nomenclature_change_status_change].delete(:secondary_output_1)
      params[:nomenclature_change_status_change].delete(:secondary_output_2)
      puts params.inspect
    end
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_status_change] || {}).merge({
        :status => (step == steps.last ? NomenclatureChange::SUBMITTED : step.to_s)
      })
    )
    success = @nomenclature_change.valid?
    case step
    when :primary_output
      set_events unless success
    end
    render_wizard @nomenclature_change
  end

end