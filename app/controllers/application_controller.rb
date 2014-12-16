class ApplicationController < ActionController::Base
  protect_from_forgery
  include SentientController
  before_filter :set_locale
  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    rescue_path = if request.referrer && request.referrer != request.url
                    request.referer
                  elsif current_user.is_api?
                    root_path
                  else
                    signed_in_root_path(current_user)
                  end

    redirect_to rescue_path, 
      :alert => if current_user.is_api?
                  "You must log out of Species+ API before you can log into this site"
                else
                  case exception.action
                    when :destroy
                      "You are not authorized to destroy that record"
                    else
                      exception.message
                  end
                end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:name)
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end


  def metadata_for_search(search)
    {
      :total => search.total_cnt,
      :page => search.page,
      :per_page => search.per_page
    }
  end

  def after_sign_out_path_for(resource_or_scope)
    admin_root_path
  end

  def signed_in_root_path(resource_or_scope)
    admin_root_path
  end

  def verify_manager
    redirect_to signed_in_root_path(current_user),
      :alert => "You are not authorized to access the trade admin page" unless current_user.is_admin?
  end
end
