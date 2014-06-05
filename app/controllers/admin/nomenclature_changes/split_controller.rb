class Admin::NomenclatureChanges::SplitController < Admin::NomenclatureChanges::BuildController

  steps :inputs, :outputs, :children, :names, :distribution, :legislation,
    :notes, :summary

  def create
    @nomenclature_change = NomenclatureChange::Split.create
    redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
  end

  def show
    input = @nomenclature_change.input
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
      default_output = if @nomenclature_change.outputs.include?(input)
        input
      else
        @nomenclature_change.outputs.first
      end
      input.input_parent_reassignments = input.taxon_concept.children.map do |child|
        reassignment_attrs = {
          :reassignable_type => 'TaxonConcept',
          :reassignable_id => child.id
        }
        reassignment = input.input_parent_reassignments.where(
          reassignment_attrs
        ).first
        unless reassignment
          reassignment = NomenclatureChange::ParentReassignment.new(
            reassignment_attrs
          )
          reassignment.build_reassignment_target(:nomenclature_change_output_id => default_output.id)
        end
        reassignment
      end
    when :names
      default_output = if @nomenclature_change.outputs.include?(input)
        input
      else
        @nomenclature_change.outputs.first
      end
      input.input_name_reassignments = [
        input.taxon_concept.synonyms.order(:full_name) +
        input.taxon_concept.hybrids.order(:full_name) +
        input.taxon_concept.trade_names.order(:full_name)
      ].flatten.map do |name|
        reassignment_attrs = {
          :reassignable_type => 'TaxonConcept',
          :reassignable_id => name.id
        }
        reassignments = input.input_name_reassignments.where(
          reassignment_attrs
        )
        if reassignments.empty?
          r = NomenclatureChange::NameReassignment.new(
            reassignment_attrs
          )
          r.reassignment_targets.build(:nomenclature_change_output_id => default_output.id)
          reassignments = [r]
        end
        reassignments
      end.flatten
    when :distribution
      default_outputs = @nomenclature_change.outputs
      input.input_distribution_reassignments = input.taxon_concept.
        distributions.includes(:geo_entity).order('geo_entities.name_en').map do |distr|
        reassignment_attrs = {
          :reassignable_type => 'Distribution',
          :reassignable_id => distr.id
        }
        reassignments = input.input_distribution_reassignments.where(
          reassignment_attrs
        )
        if reassignments.empty?
          reassignments = default_outputs.map do |default_output|
            r = NomenclatureChange::DistributionReassignment.new(
              reassignment_attrs
            )
            r.reassignment_targets.build(:nomenclature_change_output_id => default_output.id)
            r
          end
        end
        reassignments
      end.flatten
    when :legislation
      input.input_legislation_reassignments = [
        input.input_legislation_reassignments.where(
          :reassignable_type => 'ListingChange'
        ).first || NomenclatureChange::LegislationReassignment.new(
          :reassignable_type => 'ListingChange'
        ),
        input.input_legislation_reassignments.where(
          :reassignable_type => 'CitesSuspension'
        ).first || NomenclatureChange::LegislationReassignment.new(
          :reassignable_type => 'CitesSuspension'
        ),
        input.input_legislation_reassignments.where(
          :reassignable_type => 'Quota'
        ).first || NomenclatureChange::LegislationReassignment.new(
          :reassignable_type => 'Quota'
        )
      ]
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