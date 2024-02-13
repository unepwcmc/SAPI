class Admin::NomenclatureChanges::SplitController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::Split::STEPS

  def show
    builder = NomenclatureChange::Split::Constructor.new(@nomenclature_change)
    case step
    when :inputs
      set_events
      set_taxonomy
      builder.build_input
    when :outputs
      set_taxonomy
      set_ranks
      builder.build_outputs
    when :notes
      builder.build_input_and_output_notes
    when :children
      builder.build_parent_reassignments
      skip_or_previous_step if @nomenclature_change.input.parent_reassignments.empty?
    when :names
      builder.build_name_reassignments
      skip_or_previous_step if @nomenclature_change.input.name_reassignments.empty?
    when :distribution
      builder.build_distribution_reassignments
      skip_or_previous_step if @nomenclature_change.input.distribution_reassignments.empty?
    when :legislation
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.input.legislation_reassignments.empty?
    when :summary
      builder.build_document_reassignments
      processor = NomenclatureChange::Split::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (nomenclature_change_split_params || {}).merge({
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
    end
    render_wizard @nomenclature_change
  end

  private

  def klass
    NomenclatureChange::Split
  end

  def nomenclature_change_split_params
    params.require(:nomenclature_change_split).permit(
      :event_id, :status,
      input_attributes: [
        :id, :_destroy,
        :nomenclature_change_id, :taxon_concept_id,
        :note_en, :note_es, :note_fr, :internal_note,
        parent_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note,
          output_ids: [],
          reassignment_target_attributes: [
            :id, :_destroy,
            :nomenclature_change_output_id,
            :nomenclature_change_reassignment_id, :note
          ]
        ],
        name_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note,
          output_ids: []
        ],
        distribution_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note,
          output_ids: []
        ],
        legislation_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note,
          output_ids: []
        ]
      ],
      outputs_attributes: [
        :id, :_destroy,
        :nomenclature_change_id, :taxon_concept_id,
        :new_taxon_concept_id, :rank_id, :new_scientific_name, :new_author_year,
        :new_name_status, :new_parent_id, :new_rank_id, :taxonomy_id,
        :note_en, :note_es, :note_fr, :internal_note, :is_primary_output,
        :output_type, :created_by_id, :updated_by_id,
        tag_list: []
        # app/models/nomenclature_change/output.rb does not have `accepts_nested_attributes_for`, so
        # xxx_attributes suppose not in-use.
        # :parent_reassignments_attributes,
        # :name_reassignments_attributes,
        # :distribution_reassignments_attributes,
        # :legislation_reassignments_attributes,
      ]
    )
  rescue ActionController::ParameterMissing
    nil
  end
end
