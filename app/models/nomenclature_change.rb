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

class NomenclatureChange < ActiveRecord::Base
  include Dictionary
  include StatusDictionary
  build_steps
  track_who_does_it
  attr_accessible :event_id, :status

  belongs_to :event

  validates :status, presence: true
  validate :cannot_update_when_locked

  def in_progress?
    ![NomenclatureChange::SUBMITTED, NomenclatureChange::CLOSED].
      include?(status)
  end

  def submitting?
    status_changed? && status == NomenclatureChange::SUBMITTED &&
      status_was != NomenclatureChange::CLOSED
  end

  def submit
    if in_progress?
      update_attribute(:status, NomenclatureChange::SUBMITTED)
    end
  end

  def cannot_update_when_locked
    if status_was == NomenclatureChange::CLOSED ||
      status_was == NomenclatureChange::SUBMITTED &&
      status != NomenclatureChange::CLOSED
      errors[:base] << "Nomenclature change is locked for updates"
      return false
    end
  end

  def next_step
    steps = self.class::STEPS
    return nil if steps.empty?
    if status == NomenclatureChange::NEW
      steps.first
    elsif self.summary?
      self.class::SUMMARY.to_sym
    elsif !in_progress?
      nil
    else
      steps[steps.index(self.status.to_sym) + 1]
    end
  end

end
