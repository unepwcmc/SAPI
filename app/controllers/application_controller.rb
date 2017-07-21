class ApplicationController < ActionController::Base
  protect_from_forgery
  include SentientController
  before_filter :set_locale
  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied, with: :access_denied_error

  protected

  def access_denied_error(exception)
    rescue_path = if request.referrer && request.referrer != request.url
                    request.referer
                  elsif current_user.is_manager_or_contributor_or_secretariat?
                    admin_root_path
                  else
                    root_path
                  end

    message = if current_user.is_manager_or_contributor?
                case exception.action
                when :destroy
                  "You are not authorised to destroy that record"
                else
                  exception.message
                end
              elsif current_user.is_secretariat?
                t('secretariat_alert')
              else
                "You are not authorised to access this page"
              end

    flash[:error] = message
    respond_to do |format|
      format.html { redirect_to rescue_path }
      format.js { render inline: "location.reload();" }
    end
  end

  def configure_permitted_parameters
    extra_parameters = [:name, :is_cites_authority, :organisation, :geo_entity_id]
    devise_parameter_sanitizer.for(:sign_up).push(*extra_parameters)
    devise_parameter_sanitizer.for(:account_update).push(*extra_parameters)
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

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_manager_or_contributor?
        admin_root_path
      else
        super
      end
  end

  def save_email
    session[:email] = params[:user][:email] || ""
  end

  def delete_email
    session.delete(:email)
  end

end
