class ElibraryRefreshDocumentSearchJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    if DocumentSearch.citations_need_refreshing?
      elapsed_time = Benchmark.realtime do
        DocumentSearch.refresh_citations_and_documents
      end
      puts "#{Time.now} Citations & documents refreshed in #{elapsed_time}s"
    elsif DocumentSearch.documents_need_refreshing?
      elapsed_time = Benchmark.realtime do
        DocumentSearch.refresh_documents
      end
      puts "#{Time.now} Documents refreshed in #{elapsed_time}s"
    end
  end
end
