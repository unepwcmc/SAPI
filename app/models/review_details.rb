# == Schema Information
#
# Table name: review_details
#
#  id                   :integer          not null, primary key
#  recommended_category :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  document_id          :integer
#  process_stage_id     :integer
#  review_phase_id      :integer
#
# Indexes
#
#  index_review_details_on_document_id       (document_id)
#  index_review_details_on_process_stage_id  (process_stage_id)
#  index_review_details_on_review_phase_id   (review_phase_id)
#
# Foreign Keys
#
#  review_details_document_id_fk       (document_id => documents.id) ON DELETE => cascade
#  review_details_process_stage_id_fk  (process_stage_id => document_tags.id)
#  review_details_review_phase_id_fk   (review_phase_id => document_tags.id)
#

class ReviewDetails < ApplicationRecord
  # Used by DocumentController.
  # attr_accessible :document_id, :review_phase_id, :process_stage_id, :recommended_category
  self.table_name = 'review_details'
  belongs_to :document, touch: true

  def self.display_name
    'Review Details'
  end
end
