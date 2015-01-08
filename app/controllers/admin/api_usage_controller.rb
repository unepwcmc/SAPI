class Admin::ApiUsageController < Admin::AdminController
  def index
    @last_30_days_requests = ApiRequest.where('created_at > ?', 30.days.ago)
    @all_requests = ApiRequest.all
  end
end
