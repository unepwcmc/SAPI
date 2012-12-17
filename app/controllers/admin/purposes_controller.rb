class Admin::PurposesController < Admin::AdminController
  inherit_resources
  def index
    @resources = Purpose.order('code').all
    render :template => 'admin/shared/admin_in_place_editor.html.erb'
  end
end