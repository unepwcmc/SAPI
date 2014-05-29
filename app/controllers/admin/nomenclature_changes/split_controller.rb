class Admin::NomenclatureChanges::SplitController < Admin::NomenclatureChanges::BuildController

  steps :inputs, :outputs, :children, :names, :distribution, :legislation,
    :notes, :summary

  def create
    @nomenclature_change = NomenclatureChange::Split.create
    redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
  end

  def show
    case step
    when :inputs
      set_events
      @nomenclature_change.build_input(
        :is_input => true
      ) if @nomenclature_change.input.nil?
    when :outputs
      @nomenclature_change.outputs.build(
        :is_input => false
      ) if @nomenclature_change.outputs.empty?
    when :children
      input = @nomenclature_change.input
      input.input_parent_reassignments = input.taxon_concept.children.map do |child|
        reassignment_attrs = {
          :reassignable_type => 'TaxonConcept',
          :reassignable_id => child.id
        }
        reassignment = input.input_parent_reassignments.where(
          reassignment_attrs
        ).first || NomenclatureChange::ParentReassignment.new(
          reassignment_attrs
        )
      end
    when :names
      input = @nomenclature_change.input
      input.input_name_reassignments = [
        input.taxon_concept.synonyms +
        input.taxon_concept.hybrids +
        input.taxon_concept.trade_names
      ].flatten.map do |name|
        reassignment_attrs = {
          :reassignable_type => 'TaxonConcept',
          :reassignable_id => name.id
        }
        reassignment = input.input_name_reassignments.where(
          reassignment_attrs
        ).first || NomenclatureChange::NameReassignment.new(
          reassignment_attrs
        )
      end
    end
    render_wizard
  end

  def update
    success = @nomenclature_change.update_attributes(params[:nomenclature_change_split])
    case step
    when :inputs
      set_events unless success
    end
    render_wizard @nomenclature_change
  end

end