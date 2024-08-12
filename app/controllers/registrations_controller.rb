class RegistrationsController < Devise::RegistrationsController
  def update
    @user = User.find(current_user.id)

    successfully_updated =
      if needs_password?
        @user.update_with_password(user_params)
      else
        @user.update_without_password(user_params)
      end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      bypass_sign_in @user
      redirect_to after_update_path_for(@user)
    else
      render 'edit'
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
  def needs_password?
    @user.email != user_params[:email] || user_params[:password].present?
  end

  def user_params
    params.require(:user).permit(
      # attributes needed by Devise and/or used in this controller.
      :name, :email, :password, :password_confirmation, :current_password,
      # other attributes were in model `attr_accessible`.
      :remember_me, :role, :terms_and_conditions, :is_cites_authority,
      :organisation, :geo_entity_id, :is_active
    )
  end
end
