class RebuildJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    Sapi.rebuild
  end
end
