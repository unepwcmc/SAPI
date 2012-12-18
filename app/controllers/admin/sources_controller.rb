class Admin::SourcesController < Admin::AdminController
  inherit_resources
  def index
    @resources = Source.order('code').all
    render :template => 'admin/shared/admin_in_place_editor'
  end
end