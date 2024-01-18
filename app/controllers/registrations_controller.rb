class RegistrationsController < Devise::RegistrationsController
  def update
    @user = User.find(current_user.id)

    successfully_updated =
      if needs_password?(@user, params)
        # TODO: not sure if this still work, need test.
        # TODO: deprecations https://github.com/heartcombo/devise/blob/main/CHANGELOG.md#400rc1---2016-02-01
        @user.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
      else
        # remove the virtual current_password attribute
        # update_without_password doesn't know how to ignore it
        params[:user].delete(:current_password)
        # TODO: not sure if this still work, need test.
        # TODO: deprecations https://github.com/heartcombo/devise/blob/main/CHANGELOG.md#400rc1---2016-02-01
        @user.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
      end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      bypass_sign_in @user
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  private

  def after_update_path_for(resource)
    if resource.is_manager_or_contributor?
      admin_root_path
    else
      super
    end
  end

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end
end
