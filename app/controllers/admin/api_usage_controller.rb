class Admin::ApiUsageController < Admin::AdminController
  def index
    @last_30_days_requests = ApiRequest.group(:response_status)
      .group_by_day(:created_at, range: 30.days.ago.midnight..Time.now).count
    @all_requests = ApiRequest.all
    @users_by_activity = ApiRequest.where('created_at > ?', 30.days.ago).group_by(&:user).sort_by { |k,v| -v.count }[0..4]
  end

  def show
    @user = User.find(params[:id])
    @last_30_days_requests = @user.api_requests.group(:response_status)
      .group_by_day(:created_at, range: 30.days.ago.midnight..Time.now).count
    @all_requests = @user.api_requests
  end
end
