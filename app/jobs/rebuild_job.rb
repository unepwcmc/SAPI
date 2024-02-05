class RebuildJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    SapiModule::rebuild
  end
end
