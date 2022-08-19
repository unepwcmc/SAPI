class Admin::ApiUsageController < Admin::AdminController
  def index
    @recent_requests = ApiRequest.recent_requests
    @users_by_activity = ApiRequest.top_50_most_active_users
  end

  def show
    @user = User.find(params[:id])
    @recent_requests = ApiRequest.recent_requests(@user)
  end
end
