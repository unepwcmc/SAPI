class Admin::AdminController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user!

  def redirect_in_production
    if Rails.env.production?
      redirect_to signed_in_root_path(current_user), alert: 'Access denied'
    end
  end

end
