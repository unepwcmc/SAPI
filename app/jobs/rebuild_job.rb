class RebuildJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    if Rails.env.production?
      # Only run on Saturday in production
      Sapi.rebuild if Date.today.saturday?
    else
      Sapi.rebuild
    end
  end
end
