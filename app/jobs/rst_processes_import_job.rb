class RstProcessesImportJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    Appsignal::CheckIn.cron(self.class.name.underscore) do
      Import::Rst::RstCases.import_all
    end
  end
end
