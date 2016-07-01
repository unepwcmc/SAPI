# == Schema Information
#
# Table name: review_details
#
#  id                   :integer          not null, primary key
#  document_id          :integer
#  review_phase_id      :integer
#  process_stage_id     :integer
#  recommended_category :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Document::ReviewDetails < ActiveRecord::Base
  attr_accessible :document_id, :review_phase_id, :process_stage_id, :recommended_category
  self.table_name = 'review_details'
  belongs_to :document, touch: true

  def self.display_name
    'Review Details'
  end

end
