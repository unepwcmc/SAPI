namespace :elibrary do
  task :refresh_document_search => :environment do
    Document.all.each do |document|
      if document.recently_updated?
        DocumentSearch.refresh
        puts "Document search refreshed!"
        break
      end
    end
  end
end
