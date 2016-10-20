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
# 1. primary output - accepted taxon
# 2. secondary output - synonym
# As part of the status swap, any associations transferred from primary
# to secondary output
class NomenclatureChange::StatusSwap < NomenclatureChange
  include NomenclatureChange::StatusChangeHelpers
  build_steps(
    :primary_output, :secondary_output, :notes, :legislation, :summary
  )
  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  validate :required_secondary_output, if: :secondary_output_or_submitting?
  validate :required_primary_output_name_status, if: :primary_output_or_submitting?
  before_validation :set_primary_output_name_status, if: :primary_output_or_submitting?
  validate :required_secondary_output_name_status, if: :secondary_output_or_submitting?
  before_validation :set_secondary_output_name_status, if: :secondary_output_or_submitting?
  before_save :build_input_for_auto_reassignments, if: :secondary_output?
  before_save :build_auto_reassignments, if: :notes?

  def required_secondary_output
    if secondary_output.nil?
      errors.add(:secondary_output, "Must have a secondary output")
      return false
    end
    true
  end

  def required_primary_output_name_status
    if primary_output && primary_output.name_status != 'A'
      errors.add(:primary_output, "Must be A taxon")
      return false
    end
    true
  end

  def required_secondary_output_name_status
    if secondary_output && secondary_output.name_status != 'S'
      errors.add(:secondary_output, "Must be S taxon")
      return false
    end
    true
  end

  def set_primary_output_name_status
    primary_output && primary_output.new_name_status = 'S'
  end

  def set_secondary_output_name_status
    secondary_output && secondary_output.new_name_status = 'A'
  end

  def needs_to_receive_associations?
    false
  end

  def needs_to_relay_associations?
    true
  end

  def build_input_for_auto_reassignments
    if input.nil? || input.taxon_concept_id.blank?
      build_input(taxon_concept_id: primary_output.taxon_concept_id)
    end
  end

  def build_auto_reassignments
    if input
      builder = NomenclatureChange::StatusSwap::Constructor.new(self)
      builder.build_parent_reassignments
      builder.build_name_reassignments
      builder.build_distribution_reassignments
      builder.build_legislation_reassignments
      builder.build_common_names_reassignments
      builder.build_references_reassignments
      builder.build_documents_reassignments
    end
    true
  end

  def new_output_rank
    secondary_output && secondary_output.taxon_concept.try(:rank) ||
    primary_output && primary_output.taxon_concept.try(:rank)
  end

end
