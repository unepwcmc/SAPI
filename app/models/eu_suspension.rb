# == Schema Information
#
# Table name: eu_decisions
#
#  id               :integer          not null, primary key
#  type             :string(255)
#  law_id           :integer
#  taxon_concept_id :integer
#  geo_entity_id    :integer
#  start_date       :datetime
#  end_date         :datetime
#  restriction      :string(255)
#  restriction_text :text
#  term_id          :integer
#  source_id        :integer
#  conditions       :boolean
#  comments         :text
#  is_current       :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  conditions_apply :boolean
#

class EuSuspension < EuDecision
end
