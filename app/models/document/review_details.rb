# == Schema Information
#
# Table name: review_details
#
#  id                      :integer          not null, primary key
#  document_id             :integer
#  review_phase_id         :integer
#  process_stage_id        :integer
#  recommended_category_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Document::ReviewDetails < ActiveRecord::Base
  attr_accessible :document_id, :review_phase_id
  self.table_name = 'review_details'

  def self.display_name; 'Review Details'; end

end
