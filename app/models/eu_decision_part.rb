# == Schema Information
#
# Table name: eu_decision_parts
#
#  id             :integer          not null, primary key
#  is_current     :boolean
#  source_id      :integer
#  term_id        :integer
#  eu_decision_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class EuDecisionPart < ActiveRecord::Base
  attr_accessible :eu_decision_id, :is_current, :source_id, :term_id
end
