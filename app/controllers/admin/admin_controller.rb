class Admin::AdminController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
  rescue_path = if request.referrer && request.referrer != request.url
                request.referer
              else
                admin_root_path
              end
    redirect_to rescue_path, :alert => case exception.action
      when :destroy
        "You are not authorized to destroy that record"
      else
        exception.message
      end
  end
end
