ActsAsTaggableOn::Tag.class_eval do
  attr_accessible :name
end

ActsAsTaggableOn::Tagging.class_eval do
  attr_accessible :tag_id, :context, :taggable, :taggable_id, :taggable_type, :tagger_id, :tagger_type
end
