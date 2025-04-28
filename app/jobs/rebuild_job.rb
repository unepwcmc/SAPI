class RebuildJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    Appsignal::CheckIn.cron(self.class.name.underscore) do
      retry_on_deadlock do
        SapiModule.rebuild
      end
    end
  end
end
