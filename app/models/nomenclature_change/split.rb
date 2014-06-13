class NomenclatureChange::Split < NomenclatureChange
  STEPS = [:inputs, :outputs, :children, :names, :distribution, :legislation, :notes]
  STATUSES = ['new', 'submitted'] + STEPS.map(&:to_s)
  build_basic_dictionary(*STATUSES)
  has_one :input, :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_many :outputs, :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  accepts_nested_attributes_for :input, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true

  validates :status, inclusion: {
    in: STATUSES,
    message: "%{value} is not a valid status"
  }
  validate :must_have_input, if: :inputs_or_submitting?
  validate :must_have_outputs, if: :outputs_or_submitting?

  def must_have_input
    if input.blank?
      errors.add(:input, "Must have one input")
      return false
    end
  end

  def must_have_outputs
    if outputs.size < 2
      errors.add(:outputs, "Must have at least two outputs")
      return false
    end
  end

  def inputs_or_submitting?
    status == NomenclatureChange::Split::INPUTS || submitting?
  end

  def outputs_or_submitting?
    status == NomenclatureChange::Split::OUTPUTS || submitting?
  end

end
