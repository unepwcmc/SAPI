# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  comment_type     :string(255)
#  commentable_type :string(255)
#  note             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :integer
#  created_by_id    :integer
#  updated_by_id    :integer
#
# Indexes
#
#  index_comments_on_commentable_and_comment_type  (commentable_id,commentable_type,comment_type)
#
# Foreign Keys
#
#  comments_created_by_id_fk  (created_by_id => users.id)
#  comments_updated_by_id_fk  (updated_by_id => users.id)
#

class Comment < ApplicationRecord
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :comment_type, :commentable_id, :commentable_type, :note,
  #   :created_by_id, :updated_by_id

  belongs_to :commentable, polymorphic: true
end
