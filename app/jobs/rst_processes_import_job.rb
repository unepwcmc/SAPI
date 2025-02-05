class RstProcessesImportJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    Appsignal::CheckIn.cron(self.class.name.tableize) do
      Import::Rst::RstCases.import_all
    end
  end
end
