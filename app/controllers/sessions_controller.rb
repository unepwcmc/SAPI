class SessionsController < Devise::SessionsController
  respond_to :html, :json

  def create
    # Remove null bytes (which postgres dislikes) and strip leading and trailing
    # spaces. If empty string, consider nil and do not bother searching.
    email_address = user_params[:email]&.gsub("\x00", '')&.strip&.presence?

    # Crude email regex to save work only. If the record actually exists, the
    # address should have already been fully validated on creation
    resource =
      /@/.match(email_address) && User.find_for_database_authentication(
        email: email_address
      )

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
      format.html { render :new, status: :unauthorized }
      format.json { render json: flash[:error], status: :unauthorized }
    end
  end

private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
