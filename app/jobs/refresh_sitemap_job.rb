class RefreshSitemapJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    Appsignal::CheckIn.cron(self.class.name.tableize) do
      retry_on_deadlock do
        ActiveRecord::Base.transaction do
          connection = ActiveRecord::Base.connection
          # Within the current transaction, increase the lock_timeout. The default
          # postgres value is 0 (infinite) but config/database.yml sets this to a
          # lower value.
          connection.execute("SET LOCAL lock_timeout='20s';")

          # https://github.com/kjvarga/sitemap_generator/issues/231
          SitemapGenerator::Interpreter.run
        end
      end
    end
  end
end
