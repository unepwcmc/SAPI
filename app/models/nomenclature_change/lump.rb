class NomenclatureChange::Lump < NomenclatureChange
  build_steps(:inputs, :outputs, :children, :names, :distribution,
    :legislation, :notes, :summary)
  attr_accessible :inputs_attributes, :output_attributes
  has_many :inputs, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_one :output, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  accepts_nested_attributes_for :inputs, :allow_destroy => true
  accepts_nested_attributes_for :output, :allow_destroy => true

  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  validate :required_inputs, if: :inputs_or_submitting?
  validate :required_inputs_ranks, if: :inputs_or_submitting?
  validate :required_outputs, if: :outputs_or_submitting?
  validate :required_ranks, if: :outputs_or_submitting?

  def required_inputs
    if inputs.size < 2
      errors.add(:inputs, "Must have at least two inputs")
      return false
    end
  end

  def required_inputs_ranks
    if inputs.map{ |i| i.taxon_concept.try(:rank_id) }.uniq.size > 1
      errors.add(:inputs, "must be of same rank")
      return false
    end
  end

  def required_outputs
    if output.blank?
      errors.add(:output, "Must have one output")
      return false
    end
  end

  def required_ranks
    if inputs.first.try(:taxon_concept).try(:rank).
        try(:name) != output.try(:taxon_concept).try(:rank).try(:name)
      errors.add(:output, "must be at same rank as inputs")
      return false
    end
  end

end
