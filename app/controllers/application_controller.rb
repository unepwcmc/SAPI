class ApplicationController < ActionController::Base
  before_action :track_who_does_it_current_user
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit

  rescue_from CanCan::AccessDenied, with: :access_denied_error

  protected

  def access_denied_error(exception)
    rescue_path =
      if request.referer && request.referer != request.url
        request.referer
      elsif current_user.is_manager_or_contributor_or_secretariat?
        admin_root_path
      else
        root_path
      end

    message =
      if current_user.is_manager_or_contributor?
        case exception.action
        when :destroy
          'You are not authorised to destroy that record'
        else
          exception.message
        end
      elsif current_user.is_secretariat?
        t('secretariat_alert')
      else
        'You are not authorised to access this page'
      end

    flash.now[:error] = message
    respond_to do |format|
      format.html { redirect_to rescue_path }
      format.js { render inline: 'location.reload();' }
    end
  end

  def configure_permitted_parameters
    extra_parameters = [ :name, :is_cites_authority, :organisation, :geo_entity_id ]
    devise_parameter_sanitizer.permit(:sign_up, keys: extra_parameters)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_parameters)
  end

  private

  def track_who_does_it_current_user
    RequestStore.store[:track_who_does_it_current_user] = current_user
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def metadata_for_search(search)
    {
      total: search.total_cnt,
      page: search.page,
      per_page: search.per_page
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
    session[:email] = params[:user][:email] || ''
  end

  def delete_email
    session.delete(:email)
  end
end
