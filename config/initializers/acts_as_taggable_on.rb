# https://thoughtbot.com/blog/rails-6-warning-message-upgrade
Rails.application.reloader.to_prepare do
  ActsAsTaggableOn::Tagging.send :include, ComparisonAttributes
end
