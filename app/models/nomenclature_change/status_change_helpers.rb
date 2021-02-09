module NomenclatureChange::StatusChangeHelpers

  def self.included(base)
    base.class_eval do
      attr_accessible :primary_output_attributes, :secondary_output_attributes,
        :input_attributes
      has_one :input, :inverse_of => :nomenclature_change,
        :class_name => NomenclatureChange::Input,
        :foreign_key => :nomenclature_change_id,
        :dependent => :destroy, autosave: true
      has_one :primary_output, -> { where is_primary_output: true },
        :inverse_of => :nomenclature_change,
        :class_name => NomenclatureChange::Output,
        :foreign_key => :nomenclature_change_id,
        :dependent => :destroy, autosave: true
      has_one :secondary_output, -> { where is_primary_output: false },
        :inverse_of => :nomenclature_change,
        :class_name => NomenclatureChange::Output,
        :foreign_key => :nomenclature_change_id,
        :dependent => :destroy, autosave: true

      accepts_nested_attributes_for :input, :allow_destroy => true
      accepts_nested_attributes_for :primary_output, :allow_destroy => true
      accepts_nested_attributes_for :secondary_output, :allow_destroy => true

      validate :required_primary_output, if: :primary_output_or_submitting?
    end
  end

  def required_primary_output
    if primary_output.nil?
      errors.add(:primary_output, "Must have a primary output")
      return false
    end
    true
  end

end
