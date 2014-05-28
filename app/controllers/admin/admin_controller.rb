class Admin::AdminController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user!
  authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_root_path, :alert => exception.message
  end
end
