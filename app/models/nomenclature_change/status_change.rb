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
  STEPS = [:primary_output, :relay_or_swap, :receive_or_swap, :notes, :summary]
  STATUSES = ['new', 'submitted'] + STEPS.map(&:to_s)
  build_basic_dictionary(*STATUSES)
  attr_accessible :primary_output_attributes, :secondary_output_attributes
  has_one :input, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_one :primary_output, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :conditions => {:is_primary_output => true},
    :dependent => :destroy
  has_one :secondary_output, :inverse_of => :nomenclature_change,
    :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :conditions => {:is_primary_output => false},
    :dependent => :destroy
  accepts_nested_attributes_for :input, :allow_destroy => true
  accepts_nested_attributes_for :primary_output, :allow_destroy => true
  accepts_nested_attributes_for :secondary_output, :allow_destroy => true

  validates :status, inclusion: {
    in: STATUSES,
    message: "%{value} is not a valid status"
  }
  validate :required_primary_output, if: :primary_output_or_submitting?
  validate :required_secondary_output, if: :relay_or_swap_or_submitting?
  validate :required_input_for_receive, if: :receive_or_swap_or_submitting?
  validate :required_input_for_relay, if: :relay_or_swap_or_submitting?

  before_validation :build_auto_input, if: :relay_or_swap_or_submitting?
  before_validation :build_auto_reassignments, if: :submitting?

  def build_auto_input
    # In case the primary output is an A / N name turning S / T
    # this same name becomes an input of the nomenclature change, so that
    # reassignments can be put in place between this input and
    # the secondary output
    if needs_to_relay_associations? && input.nil?
      build_input(taxon_concept_id: primary_output.taxon_concept_id)
    end
  end

  def build_auto_reassignments
    builder = NomenclatureChange::StatusChange::Constructor.new(self)
    builder.build_reassignments
  end

  def required_primary_output
    if primary_output.nil?
      errors.add(:primary_output, "Must have a primary output")
      return false
    end
  end

  # we only need two outputs if we need a target for reassignments
  # (which happens when one of the outputs is an A/N name turning S/T)
  def required_secondary_output
    if needs_to_relay_associations? && secondary_output.nil?
      errors.add(:secondary_output, "Must have a secondary output")
      return false
    end
  end

  # we need an auto input if one of the outputs is an A/N name turning S/T
  def required_input_for_relay
    if needs_to_relay_associations? && (
      input.nil? || input.taxon_concept_id != primary_output.taxon_concept_id
      )
      errors.add(:inputs, "Must have auto input")
      return false
    end
  end

  # we need an input if one of the outputs is an S/T name turning A/N
  def required_input_for_receive
    if needs_to_receive_associations? && input.nil?
      errors.add(:inputs, "Must have input")
      return false
    end
  end

  def needs_to_relay_associations?
    ['A', 'N'].include?(primary_output.try(:taxon_concept).try(:name_status)) &&
      ['S', 'T'].include?(primary_output.try(:new_name_status))
  end

  def needs_to_receive_associations?
    ['S', 'T'].include?(primary_output.try(:taxon_concept).try(:name_status)) &&
      ['A', 'N'].include?(primary_output.try(:new_name_status))
  end

  def is_swap?
    secondary_output &&
      secondary_output.new_name_status == primary_output.taxon_concept.name_status
  end

  def primary_output_or_submitting?
    status == NomenclatureChange::StatusChange::PRIMARY_OUTPUT || submitting?
  end

  def relay_or_swap_or_submitting?
    status == NomenclatureChange::StatusChange::RELAY_OR_SWAP || submitting?
  end

  def receive_or_swap_or_submitting?
    status == NomenclatureChange::StatusChange::RECEIVE_OR_SWAP || submitting?
  end

end
