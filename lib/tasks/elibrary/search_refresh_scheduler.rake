namespace :elibrary do
  task :refresh_document_search => :environment do
    if DocumentSearch.needs_refreshing?
      elapsed_time = Benchmark.realtime do
        DocumentSearch.refresh
      end
      puts "#{Time.now} Document search refreshed in #{elapsed_time}s"
    end
  end
end
