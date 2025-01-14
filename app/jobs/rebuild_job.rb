class RebuildJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    retry_on_deadlock do
      SapiModule.rebuild
    end
  end
end
