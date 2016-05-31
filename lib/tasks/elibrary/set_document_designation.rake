namespace :elibrary do
  task :set_document_designation => :environment do
    cites = Designation.find_by_name('CITES')
    Document.joins(:event).where(
      'events.type' => ['CitesCop', 'CitesTc', 'CitesPc', 'CitesAc', 'CitesExtraordinaryMeeting']
    ).update_all(designation_id: cites.id)
    eu = Designation.find_by_name('EU')
    Document.joins(:event).where(
      'events.type' => 'EcSrg'
    ).update_all(designation_id: eu.id)
  end
end
