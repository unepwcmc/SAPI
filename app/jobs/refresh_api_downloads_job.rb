require 'open3'

##
# Strictly, this ought to be a job in the Species+ API repo.
# It's here to avoid having new Redis, sidekiq instances just for one job.
class RefreshApiDownloadsJob < ApplicationJob
  def perform(*_args)
    rake_command = 'db:version' # api:dump
    full_command = "cd ~/species-api/current/ && bundle exec rake #{rake_command}"

    Open3.popen3(full_command) do |stdin, stdout, stderr, wait_thr|
      stdin.close

      raise "Error: #{stderr.read}" if wait_thr.value.exitstatus > 0

      puts "Output: #{stdout.read}"
    end
  end
end
