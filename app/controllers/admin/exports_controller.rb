class Admin::ExportsController < Admin::AdminController

  def index; end

  def download
    result = Species::TaxonConceptsNamesExport.new(params[:filters]).export
    if result.is_a?(Array)
      send_file result[0], result[1]
    else
      redirect_to admin_exports_path, :notice => "There are no #{params[:data_type]} to download."
    end
  end

end
