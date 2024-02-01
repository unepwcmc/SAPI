# Migrated to Strong Parameters
# ActsAsTaggableOn::Tag.class_eval do
#   attr_accessible :name
# end

# ActsAsTaggableOn::Tagging.class_eval do
#   attr_accessible :tag_id, :context, :taggable, :taggable_id, :taggable_type, :tagger_id, :tagger_type
# end



# TODO
# DEPRECATION WARNING: Initialization autoloaded the constant ComparisonAttributes.
#
# Being able to do this is deprecated. Autoloading during initialization is going
# to be an error condition in future versions of Rails.
#
# Reloading does not reboot the application, and therefore code executed during
# initialization does not run again. So, if you reload ComparisonAttributes, for example,
# the expected changes won't be reflected in that stale Module object.
#
# `config.autoloader` is set to `classic`. This autoloaded constant would have been unloaded if `config.autoloader` had been set to `:zeitwerk`.
#
# Please, check the "Autoloading and Reloading Constants" guide for solutions.
#  (called from <top (required)> at /SAPI/config/environment.rb:5)
ActsAsTaggableOn::Tagging.send :include, ComparisonAttributes
