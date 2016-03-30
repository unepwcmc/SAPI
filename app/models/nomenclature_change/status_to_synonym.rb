# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  type          :string(255)      not null
#  status        :string(255)      not null
#  created_by_id :integer          not null
#  updated_by_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# A status change to S needs to have at least one output and at most two
# The case where there are 2 is as follows:
# N taxon t1 (input) downgraded to synonym t1 (output1),
# with any associations transferred to accepted taxon t2 (output2)

# As a rule of thumb, if there are 2 outputs that means there are reassignments
# involved between the input and one of the outputs.
class NomenclatureChange::StatusToSynonym < NomenclatureChange
  include NomenclatureChange::StatusChangeHelpers
  build_steps(
    :primary_output, :relay, :accepted_name, :legislation, :summary
  )
  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  validate :required_primary_output_name_status, if: :primary_output_or_submitting?
  validate :required_secondary_output, if: :relay_or_submitting?
  before_save :build_input_for_relay, if: :relay?
  after_save :build_auto_reassignments, if: :relay?
  before_validation :ensure_new_name_status, if: :primary_output?

  def ensure_new_name_status
    primary_output && primary_output.new_name_status = 'S'
  end

  def required_primary_output_name_status
    if primary_output && !['N', 'T'].include?(primary_output.name_status)
      errors.add(:primary_output, "Must be N or T taxon")
      return false
    end
    true
  end

  # we only need two outputs if we need a target for reassignments
  # (which happens when one of the outputs is an N name turning S)
  def required_secondary_output
    if (needs_to_relay_associations? || requires_accepted_name_assignment?) &&
      secondary_output.nil?
      errors.add(:secondary_output, "Must have a secondary output")
      return false
    end
    true
  end

  def build_input_for_relay
    # In case the primary output is a N name turning S
    # this same name becomes an input of the nomenclature change, so that
    # reassignments can be put in place between this input and
    # the secondary output
    if needs_to_relay_associations? && input.nil?
      build_input(taxon_concept_id: primary_output.taxon_concept_id)
    end
  end

  def needs_to_receive_associations?
    false
  end

  def needs_to_relay_associations?
    primary_output.try(:name_status) == 'N'
  end

  def requires_accepted_name_assignment?
    primary_output.try(:name_status) == 'T'
  end

  def build_auto_reassignments
    # Reassignments will only be required when there is an input
    # from which to reassign
    if input
      builder = NomenclatureChange::StatusToSynonym::Constructor.new(self)
      builder.build_parent_reassignments
      builder.build_name_reassignments
      builder.build_distribution_reassignments
      builder.build_legislation_reassignments
      builder.build_common_names_reassignments
      builder.build_references_reassignments
    end
    true
  end

end
