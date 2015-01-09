class Admin::ApiUsageController < Admin::AdminController
  def index
    @last_30_days_requests = ApiRequest.group(:response_status)
      .group_by_day(:created_at, range: 30.days.ago.midnight..Time.now).count

    @all_requests = ApiRequest.all
  end
end
