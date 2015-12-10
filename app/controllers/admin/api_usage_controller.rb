class Admin::ApiUsageController < Admin::AdminController
  def index
    @last_30_days_requests = ApiRequest.last_30_days_requests
    @users_by_activity = ApiRequest.top_5_most_active_users
  end

  def show
    @user = User.find(params[:id])
    @last_30_days_requests = @user.last_30_days_api_requests
  end
end
