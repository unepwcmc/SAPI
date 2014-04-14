class Admin::ExportsController < Admin::AdminController

  def index; end

  def download
    case params[:data_type]
      when 'Names'
        result = Species::TaxonConceptsNamesExport.new(params[:filters]).export
      when 'SynonymsAndTradeNames'
        result = Species::SynonymsAndTradeNamesExport.new(params[:filters]).export
      when 'CommonNames'
        result = Species::CommonNamesExport.new(params[:filters]).export
      when 'SpeciesReferenceOutput'
        result = Species::SpeciesReferenceOutputExport.new().export
      when 'Distributions'
        result = Species::TaxonConceptsDistributionsExport.new(params[:filters]).export
    end
    if result.is_a?(Array)
      send_file result[0], result[1]
    else
      redirect_to admin_exports_path, :notice => "There are no #{params[:data_type]} to download."
    end
  end

end
