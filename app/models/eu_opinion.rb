# == Schema Information
#
# Table name: eu_decisions
#
#  id                  :integer          not null, primary key
#  is_current          :boolean
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
#

class EuOpinion < EuDecision
end
