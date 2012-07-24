class TaxonConceptsController < ApplicationController

  def index
    extract_checklist_params
    if params[:format] == 'pdf'
      send_data(PdfChecklist.new(@checklist_params).generate.render,
        :filename => "index_of_CITES_species.pdf",
        :type => :pdf)
    else
      render :json => Checklist.new(@checklist_params).custom_json
    end
  end

  def history
    extract_checklist_params
    if params[:format] == 'pdf'
      send_data(PdfChecklistHistory.new(@checklist_params).generate.render,
        :filename => "history_of_CITES_listings.pdf")
    else
      render :json => ChecklistHistory.new(@checklist_params).custom_json
    end
  end

  private
  def extract_checklist_params
    @checklist_params = {
      :country_ids => params[:country_ids] ? params[:country_ids] : nil,
      :cites_region_ids =>
        params[:cites_region_ids] ? params[:cites_region_ids] : nil,
      :cites_appendices =>
        params[:cites_appendices] ? params[:cites_appendices] : nil,
      :output_layout =>
        params[:output_layout] ? params[:output_layout].to_sym : nil,
      :common_names =>
        params[:common_names] ? params[:common_names] : ['E','F','S']
    }
  end

end
