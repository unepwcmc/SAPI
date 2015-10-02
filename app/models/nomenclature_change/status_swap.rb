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

# A status swap requires 2 outputs.
# 1. accepted taxon t1 (input) downgraded to synonym t1 (output1), as part of
# status swap with synonym t2, with any associations transferred to accepted
# taxon t2 (output2)
# 2. synonym t1 upgraded to accepted taxon t1 (output1), as part of status swap
# with accepted taxon t2 (input), which becomes synonym t2 (output2), with
# any associations of t2 transferred to t1
class NomenclatureChange::StatusSwap < NomenclatureChange
  include NomenclatureChange::StatusChangeHelpers
  build_steps(
    :primary_output, :swap, :legislation, :summary
  )
  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  before_save :build_input_for_swap, if: :swap?
  before_save :build_auto_reassignments, if: :legislation?

  def build_input_for_swap
    # In case the primary output is an S name turning A
    # as part of status swap with another A name
    # the secondary output becomes a pseudo-input for reassignments
    # to the primary output.
    # In case the primary output is an A name turning S
    # as part of status swap with anoter S name
    # the primary output becomes a pseudo-input for reassignments
    # to the secondary output.
    if needs_to_receive_associations? && (
      input.nil? || input.taxon_concept_id.blank?)
      build_input(taxon_concept_id: secondary_output.taxon_concept_id)
    elsif needs_to_relay_associations? && (
      input.nil? || input.taxon_concept_id.blank?)
      build_input(taxon_concept_id: primary_output.taxon_concept_id)
    end
  end

  def needs_to_receive_associations?
    primary_output.try(:name_status) == 'S' &&
      primary_output.try(:new_name_status) == 'A'
  end

  def needs_to_relay_associations?
    primary_output.try(:name_status) == 'A' &&
      primary_output.try(:new_name_status) == 'S'
  end

  def build_auto_reassignments
    # Reassignments will only be required when there is an input
    # from which to reassign
    if input
      builder = NomenclatureChange::StatusSwap::Constructor.new(self)
      builder.build_parent_reassignments
      builder.build_name_reassignments
      builder.build_distribution_reassignments
      builder.build_legislation_reassignments
      builder.build_common_names_reassignments
      builder.build_references_reassignments
      builder.build_trade_reassignments
    end
    true
  end

end
