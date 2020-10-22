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

# A status change to A needs to have one output.
class NomenclatureChange::StatusToAccepted < NomenclatureChange
  include NomenclatureChange::StatusChangeHelpers
  attr_accessible :created_by_id, :updated_by_id
  build_steps(
    :primary_output, :summary
  )
  validates :status, inclusion: {
    in: self.status_dict,
    message: "%{value} is not a valid status"
  }
  validate :required_primary_output_name_status, if: :primary_output_or_submitting?
  before_validation :set_output_name_status, if: :primary_output_or_submitting?
  before_validation :set_output_rank_id, if: :primary_output_or_submitting?
  before_validation :set_output_parent_id, if: :primary_output_or_submitting?

  def required_primary_output_name_status
    if primary_output && !['N', 'T'].include?(primary_output.name_status)
      errors.add(:primary_output, "Must be N or T taxon")
      return false
    end
    true
  end

  def set_output_name_status
    primary_output && primary_output.new_name_status = 'A'
  end

  def set_output_rank_id
    return true if primary_output && primary_output.new_rank_id.present?
    primary_output && primary_output.taxon_concept &&
      primary_output.new_rank_id = primary_output.taxon_concept.rank_id
  end

  def set_output_parent_id
    return true unless needs_to_set_parent? && primary_output.new_parent_id.nil?
    primary_output && primary_output.taxon_concept &&
      primary_output.new_parent_id = primary_output.default_parent.try(:id)
  end

  def new_output_rank
    primary_output && primary_output.taxon_concept.try(:rank)
  end

  def needs_to_receive_associations?
    false
  end

  def needs_to_relay_associations?
    false
  end

  def needs_to_set_parent?
    primary_output.try(:name_status) == 'T'
  end

end
