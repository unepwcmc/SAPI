# A status change needs to have at least one output and at most two
# The cases where there are 2 are as follows:
# 1. accepted taxon t1 (input) downgraded to synonym t1 (output1),
# with any associations transferred to accepted taxon t2 (output2)
# 2. accepted taxon t1 (input) downgraded to synonym t1 (output1), as part of
# status swap with synonym t2, with any associations transferred to accepted
# taxon t2 (output2)
# 3. synonym t1 upgraded to accepted taxon t1 (output1), as part of status swap
# with accepted taxon t2 (input), which becomes synonym t2 (output2), with
# any associations of t2 transferred to t1
# As a rule of thumb, if there are 2 outputs that means there are reassignments
# involved between the input and one of the outputs.
class NomenclatureChange::StatusChange < NomenclatureChange
  STEPS = [:outputs, :inputs, :notes, :summary]
  STATUSES = ['new', 'submitted'] + STEPS.map(&:to_s)
  build_basic_dictionary(*STATUSES)
  has_one :input, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_many :outputs, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  accepts_nested_attributes_for :input, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true

  validates :status, inclusion: {
    in: STATUSES,
    message: "%{value} is not a valid status"
  }
  validate :required_outputs, if: :outputs_or_submitting?
  #before_validation :build_required_inputs, if: :outputs_or_submitting?
  validate :required_inputs, if: :inputs_or_submitting?

  # we only need two outputs if we need a target for reassignments
  # (which happens when one of the outputs is an A/N name turning S/T)
  def required_outputs
    if outputs.empty?
      errors.add(:outputs, "Must have at least one output")
      return false
    end
    if output_that_needs_reassignments && outputs.size < 2
      errors.add(:outputs, "Must have two outputs")
      return false
    end
    if outputs.size > 2
      errors.add(:outputs, "Must have at most two outputs")
      return false
    end
  end

  # we only need an input if one of the outputs is an A/N name turning S/T
  def required_inputs
    output = output_that_needs_reassignments
    if output && (input.nil || input.taxon_concept_id != output.taxon_concept_id)
      errors.add(:inputs, "Must have an input for accepted name reassignments")
      return false
    end
  end

  def has_auto_input?
    needs_reassignments? && input
  end

  def needs_reassignments?
    output_that_needs_reassignments
  end

  def output_that_needs_reassignments
    outputs.select do |output|
      ['A', 'N'].include?(output.try(:taxon_concept).try(:name_status)) &&
        ['S', 'T'].include?(output.new_name_status)
    end.first
  end

  def output_that_receives_reassignments
    (outputs - [output_that_needs_reassignments]).first
  end

end
