class Admin::NomenclatureChanges::SplitController < Admin::NomenclatureChanges::BuildController

  steps :inputs, :outputs, :children, :names, :distribution, :legislation,
    :notes, :summary

  def create
    @nomenclature_change = NomenclatureChange::Split.create(:status => 'new')
    redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
  end

  def show
    input = @nomenclature_change.input
    case step
    when :inputs
      set_events
      @nomenclature_change.build_input if @nomenclature_change.input.nil?
    when :outputs
      @nomenclature_change.outputs.build if @nomenclature_change.outputs.empty?
    when :children
      default_output = if @nomenclature_change.outputs.include?(input)
        input
      else
        @nomenclature_change.outputs.first
      end
      children = input.taxon_concept.children - @nomenclature_change.
        outputs.map(&:taxon_concept).compact
      input.parent_reassignments = children.map do |child|
        reassignment_attrs = {
          :reassignable_type => 'TaxonConcept',
          :reassignable_id => child.id
        }
        reassignment = input.parent_reassignments.where(
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
      input.name_reassignments = [
        input.taxon_concept.synonym_relationships.
          includes(:other_taxon_concept).
          order('taxon_concepts.full_name') +
        input.taxon_concept.hybrid_relationships.
          includes(:other_taxon_concept).
          order('taxon_concepts.full_name') +
        input.taxon_concept.trade_name_relationships.
          includes(:other_taxon_concept).
          order('taxon_concepts.full_name')
        # TODO other relationships
      ].flatten.map do |relationship|
        reassignment_attrs = {
          :reassignable_type => 'TaxonRelationship',
          :reassignable_id => relationship.id
        }
        reassignments = input.name_reassignments.where(
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
      input.distribution_reassignments = input.taxon_concept.
        distributions.includes(:geo_entity).order('geo_entities.name_en').map do |distr|
        reassignment_attrs = {
          :reassignable_type => 'Distribution',
          :reassignable_id => distr.id
        }
        reassignments = input.distribution_reassignments.where(
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
      event = @nomenclature_change.event
      input.legislation_reassignments = [
        input.legislation_reassignments.where(
          :reassignable_type => 'ListingChange'
        ).first || NomenclatureChange::LegislationReassignment.new(
          :reassignable_type => 'ListingChange',
          :note => "Originally listed as #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
        ),
        input.legislation_reassignments.where(
          :reassignable_type => 'CitesSuspension'
        ).first || NomenclatureChange::LegislationReassignment.new(
          :reassignable_type => 'CitesSuspension',
          :note => "Suspension originally formed for #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
        ),
        input.legislation_reassignments.where(
          :reassignable_type => 'Quota'
        ).first || NomenclatureChange::LegislationReassignment.new(
          :reassignable_type => 'Quota',
          :note => "Quota originally published for #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
        ),
        input.legislation_reassignments.where(
          :reassignable_type => 'EuSuspension'
        ).first || NomenclatureChange::LegislationReassignment.new(
          :reassignable_type => 'EuSuspension',
          :note => "Suspension originally formed for #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
        ),
        input.legislation_reassignments.where(
          :reassignable_type => 'EuOpinion'
        ).first || NomenclatureChange::LegislationReassignment.new(
          :reassignable_type => 'EuOpinion',
          :note => "Opinion originally formed for #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
        )
      ]
    when :notes
      event = @nomenclature_change.event
      unless input.reassignments.where(
        :reassignable_type => 'TaxonCommon'
      ).first
        input.reassignments << NomenclatureChange::Reassignment.new(
          :reassignable_type => 'TaxonCommon',
          :type => 'NomenclatureChange::Reassignment'
        )
      end
      unless input.reassignments.where(
        :reassignable_type => 'TaxonConceptReference'
      ).first
        input.reassignments << NomenclatureChange::Reassignment.new(
          :reassignable_type => 'TaxonConceptReference',
          :type => 'NomenclatureChange::Reassignment'
        )
      end
      if input.note.blank?
        outputs = @nomenclature_change.outputs.map{ |output| output.display_full_name }.join(', ')
        input.note = "#{input.taxon_concept.full_name} was split into #{outputs} following taxonomic changes adopted at #{event.try(:name)}"
      end
      @nomenclature_change.outputs.each do |output|
        if output.note.blank?
          output.note = "#{output.display_full_name} was split from #{input.taxon_concept.full_name} in #{Date.today.year} following taxonomic changes adopted at #{event.try(:name)}"
        end
      end
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