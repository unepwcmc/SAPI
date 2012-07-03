class TaxonConceptsController < ApplicationController
  def index
    c = Checklist.new({
      :country_ids => params[:country_ids] ? params[:country_ids] : nil,
      :cites_region_ids => params[:cites_region_ids] ? params[:cites_region_ids] : nil,
      :cites_appendices => params[:cites_appendices] ? params[:cites_appendices] : nil,
      :output_layout => params[:output_layout] ? params[:output_layout].to_sym : nil,
      :common_names => params[:common_names] ? params[:common_names] : ['E','F','S']
    })
    render :json => c.generate
  end
end
