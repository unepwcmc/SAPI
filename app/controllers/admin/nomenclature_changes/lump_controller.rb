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
      builder.build_input
    when :outputs
      builder.build_outputs
    when :children
      builder.build_parent_reassignments
    when :names
      builder.build_name_reassignments
    when :distribution
      builder.build_distribution_reassignments
    when :legislation
      builder.build_legislation_reassignments
    when :notes
      builder.build_common_names_reassignments
      builder.build_references_reassignments
      builder.build_input_and_output_notes
    when :summary
      @summary = NomenclatureChange::Lump::Summarizer.new(@nomenclature_change).summary
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
    when :inputs
      set_events unless success
    end
    render_wizard @nomenclature_change
  end

end
