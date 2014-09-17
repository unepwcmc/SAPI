# == Schema Information
#
# Table name: documents
#
#  id                       :integer               not null, primary key
#  document_id              :integer
#  review_phase_id          :integer
#  process_stage_id         :integer
#  recommended_category_id  :integer
#  created_by_id            :integer
#  updated_by_id            :integer
#

class Document::ReviewDetails < ActiveRecord::Base
  self.table_name = 'review_details'

  def self.display_name; 'Review Details'; end
end
