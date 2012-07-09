class TaxonConceptsController < ApplicationController

  def index
    checklist_params = {
      :country_ids => params[:country_ids] ? params[:country_ids] : nil,
      :cites_region_ids => params[:cites_region_ids] ? params[:cites_region_ids] : nil,
      :cites_appendices => params[:cites_appendices] ? params[:cites_appendices] : nil,
      :output_layout => params[:output_layout] ? params[:output_layout].to_sym : nil,
      :common_names => params[:common_names] ? params[:common_names] : ['E','F','S']
    }
    if params[:format] == 'pdf'
      send_data(PdfChecklist.new(checklist_params).generate.render, :filename => "checklist.pdf")
    else
      render :json => Checklist.new(checklist_params).generate
    end
  end
end
