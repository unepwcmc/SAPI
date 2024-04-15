class RstProcessesImportJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    Import::Rst::RstCases.import_all
  end
end
