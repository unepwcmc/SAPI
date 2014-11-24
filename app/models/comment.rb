# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_id   :integer
#  commentable_type :string(255)
#  comment_type     :string(255)
#  note             :text
#  created_by_id    :integer
#  updated_by_id    :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Comment < ActiveRecord::Base
  track_who_does_it
  attr_accessible :comment_type, :commentable_id, :commentable_type, :note,
    :created_by_id, :updated_by_id
  belongs_to :commentable, polymorphic: true
end
