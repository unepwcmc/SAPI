class Admin::ExportsController < Admin::AdminController

  def index; end

  def download
    filters = (params[:filters] || {}).merge({
      :csv_separator =>
        if params[:filters] && params[:filters][:csv_separator] &&
          params[:filters][:csv_separator].downcase.strip.to_sym == :semicolon
          :semicolon
        else
          :comma
        end
    })
    case params[:data_type]
    when 'Names'
      result = Species::TaxonConceptsNamesExport.new(filters).export
    when 'SynonymsAndTradeNames'
      result = Species::SynonymsAndTradeNamesExport.new(filters).export
    when 'CommonNames'
      result = Species::CommonNamesExport.new(filters).export
    when 'OrphanedTaxonConcepts'
      result = Species::OrphanedTaxonConceptsExport.new(filters).export
    when 'SpeciesReferenceOutput'
      result = Species::SpeciesReferenceOutputExport.new(filters).export
    when 'StandardReferenceOutput'
      result = Species::StandardReferenceOutputExport.new(filters).export
    when 'Distributions'
      result = Species::TaxonConceptsDistributionsExport.new(filters).export
    when 'Documents'
      result = Species::DocumentsExport.new(filters).export
    when 'IdMaterials'
      result = Species::IdManualDocumentsExport.new.export
    when 'IucnMappings'
      result = Species::IucnMappingsExport.new.export
    when 'CmsMappings'
      result = Species::CmsMappingsExport.new.export
    end
    if result.is_a?(Array)
      # this was added in order to prevent download managers from
      # failing when chunked_transfer_encoding is set in nginx (1.8.1)
      file_path = Pathname.new(result[0]).realpath
      response.headers['Content-Length'] = File.size(file_path).to_s
      send_file file_path, result[1]
    else
      redirect_to admin_exports_path, :notice => "There are no #{params[:data_type]} to download."
    end
  end

end
