class Admin::DocumentsController < Admin::SimpleCrudController

  def create
    params[:files].each do |file|
      debugger
    end
  end

end
