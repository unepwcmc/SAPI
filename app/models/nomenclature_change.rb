# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  status        :string(255)      not null
#  type          :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer          not null
#  event_id      :integer
#  updated_by_id :integer          not null
#
# Indexes
#
#  index_nomenclature_changes_on_created_by_id  (created_by_id)
#  index_nomenclature_changes_on_event_id       (event_id)
#  index_nomenclature_changes_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  nomenclature_changes_created_by_id_fk  (created_by_id => users.id)
#  nomenclature_changes_event_id_fk       (event_id => events.id)
#  nomenclature_changes_updated_by_id_fk  (updated_by_id => users.id)
#

class NomenclatureChange < ApplicationRecord
  include Dictionary
  include StatusDictionary

  build_steps

  include TrackWhoDoesIt

  # Migrated to controller (Strong Parameters)
  # attr_accessible :event_id, :status

  belongs_to :event, optional: true

  validates :status, presence: true
  validate :cannot_update_when_locked

  after_save do
    if status == self.class::SUBMITTED
      Rails.logger.warn "SUBMIT #{type}"
      begin
        processor_klass = "#{type}::Processor".constantize
      rescue NameError
        Rails.logger.warn "No processor found for #{type}"
      else
        processor_klass.new(self).run
      end
    end
  end

  def in_progress?
    [ NomenclatureChange::SUBMITTED, NomenclatureChange::CLOSED ].exclude?(status)
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
      (status_was == NomenclatureChange::SUBMITTED &&
      status != NomenclatureChange::CLOSED)
      errors.add(:base, 'Nomenclature change is locked for updates')
      false
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
