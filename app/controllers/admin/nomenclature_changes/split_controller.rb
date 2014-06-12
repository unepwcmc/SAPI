class Admin::NomenclatureChanges::SplitController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::Split::STEPS

  def create
    @nomenclature_change = NomenclatureChange::Split.create(:status => :new)
    redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
  end

  def show
    builder = NomenclatureChange::Split::Constructor.new(@nomenclature_change)
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
    end
    render_wizard
  end

  def update
    status_attrs = {:status => (step == steps.last ? 'submitted' : step.to_s)}
    success = @nomenclature_change.update_attributes(
      (params[:nomenclature_change_split] || {}).merge(status_attrs)
    )
    case step
    when :inputs
      set_events unless success
    end
    render_wizard @nomenclature_change
  end

end