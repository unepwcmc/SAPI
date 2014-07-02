class Admin::NomenclatureChanges::LumpController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::Lump::STEPS

  def create
    @nomenclature_change = NomenclatureChange::Lump.new(:status => NomenclatureChange::NEW)
    if @nomenclature_change.save
      redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
    else
      redirect_to admin_nomenclature_changes_url, :alert => "Could not start a new nomenclature change"
    end
  end

  def show
    builder = NomenclatureChange::Lump::Constructor.new(@nomenclature_change)
    case step
    when :inputs
      set_events
      set_taxonomy
      builder.build_inputs
    when :outputs
      set_taxonomy
      builder.build_output
    when :notes
      builder.build_common_names_reassignments
      builder.build_references_reassignments
      builder.build_input_and_output_notes
    when :children
      builder.build_parent_reassignments
      skip_or_previous_step if @nomenclature_change.inputs.map(&:parent_reassignments).flatten.empty?
    when :names
      builder.build_name_reassignments
      skip_or_previous_step if @nomenclature_change.inputs.map(&:name_reassignments).flatten.empty?
    when :distribution
      builder.build_distribution_reassignments
      skip_or_previous_step if @nomenclature_change.inputs.map(&:distribution_reassignments).flatten.empty?
    when :legislation
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.inputs.map(&:legislation_reassignments).flatten.empty?
    when :summary
      @summary = NomenclatureChange::Lump::Summarizer.new(@nomenclature_change).summary
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
    when :inputs
      unless success
        set_events
        set_taxonomy
      end
    end
    render_wizard @nomenclature_change
  end

end
