class Admin::NomenclatureChanges::LumpController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::Lump::STEPS

  def show
    builder = NomenclatureChange::Lump::Constructor.new(@nomenclature_change)
    case step
    when :inputs
      set_events
      set_taxonomy
      builder.build_inputs
    when :outputs
      set_taxonomy
      set_ranks
      builder.build_output
    when :notes
      builder.build_input_and_output_notes
      builder.build_parent_reassignments
      builder.build_name_reassignments
      builder.build_distribution_reassignments
    when :legislation
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.inputs.map(&:legislation_reassignments).flatten.empty?
    when :summary
      builder.build_document_reassignments
      processor = NomenclatureChange::Lump::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (nomenclature_change_lump_params || {}).merge({
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
    when :outputs
      unless success
        set_taxonomy
        set_ranks
      end
    end
    render_wizard @nomenclature_change
  end

  private

  def klass
    NomenclatureChange::Lump
  end

  def nomenclature_change_lump_params
    params.require(:nomenclature_change_lump).permit(
      :event_id, :status,
      inputs_attributes: [
        :nomenclature_change_id, :taxon_concept_id,
        :note_en, :note_es, :note_fr, :internal_note,
        parent_reassignments_attributes: [
          :id, :_destroy,
          :reassignment_target_attributes,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note, :output_ids
        ],
        name_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note, :output_ids
        ],
        distribution_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note, :output_ids
        ],
        legislation_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note, :output_ids
        ]
      ],
      output_attributes: [
        :nomenclature_change_id, :taxon_concept_id,
        :new_taxon_concept_id, :rank_id, :new_scientific_name, :new_author_year,
        :new_name_status, :new_parent_id, :new_rank_id, :taxonomy_id,
        :note_en, :note_es, :note_fr, :internal_note, :is_primary_output,
        :output_type, :tag_list, :created_by_id, :updated_by_id
        # app/models/nomenclature_change/output.rb does not have `accepts_nested_attributes_for`, so
        # xxx_attributes suppose not in-use.
        # :parent_reassignments_attributes,
        # :name_reassignments_attributes,
        # :distribution_reassignments_attributes,
        # :legislation_reassignments_attributes,
      ]
    )
  end
end
