class RefreshSitemapJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    # https://github.com/kjvarga/sitemap_generator/issues/231
    SitemapGenerator::Interpreter.run
  end
end
