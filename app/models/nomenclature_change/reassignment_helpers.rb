module NomenclatureChange::ReassignmentHelpers
  def self.included(base)
    base.class_eval do
      include TrackWhoDoesIt

      # Migrated to controller (Strong Parameters)
      # attr_accessible :type, :reassignable_id, :reassignable_type,
      #   :nomenclature_change_input_id, :nomenclature_change_output_id,
      #   :note_en, :note_es, :note_fr, :internal_note, :output_ids
      belongs_to :reassignable, polymorphic: true, optional: true
      has_many :reassignment_targets,
        inverse_of: :reassignment,
        class_name: 'NomenclatureChange::ReassignmentTarget',
        foreign_key: :nomenclature_change_reassignment_id,
        dependent: :destroy,
        autosave: true
      has_many :outputs, through: :reassignment_targets

      validates :reassignable_type, presence: true
    end
  end

  def note_with_resolved_placeholders_en(input, output)
    note_with_resolved_placeholders(note_en, input, output)
  end

  def note_with_resolved_placeholders_es(input, output)
    note_with_resolved_placeholders(note_es, input, output)
  end

  def note_with_resolved_placeholders_fr(input, output)
    note_with_resolved_placeholders(note_fr, input, output)
  end

  def internal_note_with_resolved_placeholders(input, output)
    note_with_resolved_placeholders(internal_note, input, output)
  end

private

  def note_with_resolved_placeholders(note, input, output)
    (note && note.
      sub('[[input]]', input.taxon_concept.full_name).
      sub('[[output]]', output.display_full_name)) || ''
  end
end
