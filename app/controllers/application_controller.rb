class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

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

end
