class Admin::UnitsController < Admin::AdminController
  inherit_resources
  def index
    @resources = Unit.order('code').all
    render :template => 'admin/shared/admin_in_place_editor'
  end
end