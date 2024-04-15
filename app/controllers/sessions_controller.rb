class SessionsController < Devise::SessionsController
  respond_to :html, :json

  def create
    resource = User.find_for_database_authentication(email: user_params[:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(user_params[:password])
      sign_in :user, resource
      set_flash_message(:notice, :signed_in)
      return respond_with resource, location: after_sign_in_path_for(resource)
    end

    invalid_login_attempt
  end

  protected

  def invalid_login_attempt
    @user = User.new
    set_flash_message(:error, :invalid)
    respond_to do |format|
      format.html { render :new, status: 401 }
      format.json { render json: flash[:error], status: 401 }
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
