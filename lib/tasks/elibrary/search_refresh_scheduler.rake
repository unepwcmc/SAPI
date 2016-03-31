namespace :elibrary do
  task :refresh_document_search => :environment do
    if Document.where('updated_at > ?', 5.minutes.ago).limit(1).count > 0
      DocumentSearch.refresh
      puts "Document search refreshed!"
    end
  end
end
