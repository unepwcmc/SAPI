# == Schema Information
#
# Table name: eu_decisions
#
#  id                  :integer          not null, primary key
#  is_current          :boolean          default(TRUE)
#  notes               :text
#  internal_notes      :text
#  taxon_concept_id    :integer
#  geo_entity_id       :integer
#  start_date          :datetime
#  start_event_id      :integer
#  end_date            :datetime
#  end_event_id        :integer
#  type                :string(255)
#  conditions_apply    :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  eu_decision_type_id :integer
#  term_id             :integer
#  source_id           :integer
#

class EuSuspension < EuDecision

  def self.search query
    if query.present?
      where("UPPER(taxon_concepts.full_name) LIKE UPPER(:query)
            ", :query => "%#{query}%")
    else
      scoped
    end
  end

  def start_date
    start_event && start_event.effective_at
  end

  def end_date
    end_event && end_event.effective_at
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%Y') : ''
  end

  def is_current
    return false if !start_event
    return start_event.effective_at <= Date.today && (
      !end_event || end_event.effective_at > Date.today )
  end
end
