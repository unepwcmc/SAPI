class ApplicationController < ActionController::API
  before_filter :set_locale
  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = params[:locale]
  end

private
  def checklist_params
    Checklist::ChecklistParams.new(params)
  end

end
