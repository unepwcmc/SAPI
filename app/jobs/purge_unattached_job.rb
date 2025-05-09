# @see https://guides.rubyonrails.org/active_storage_overview.html#purging-unattached-uploads
class PurgeUnattachedJob < ApplicationJob
  def perform(*_args)
    ActiveStorage::Blob.unattached.where(
      created_at: ..2.days.ago
    ).find_each(&:purge)
  end
end
