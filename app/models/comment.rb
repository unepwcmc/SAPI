class Comment < ActiveRecord::Base
  track_who_does_it
  attr_accessible :comment_type, :commentable_id, :commentable_type, :note,
    :created_by_id, :updated_by_id
  belongs_to :commentable, polymorphic: true
end
