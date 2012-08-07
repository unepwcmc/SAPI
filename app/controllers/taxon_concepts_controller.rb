class TaxonConceptsController < ApplicationController

  def index
    extract_checklist_params
    if params[:format] == 'pdf'
      download_path = PdfChecklist.new(@checklist_params).generate

      send_file(download_path,
        :filename => "index_of_CITES_species.pdf",
        :type => :pdf)

      # Clean up after ourselves
      FileUtils.rm download_path
    else
      render :json => Checklist.new(@checklist_params).
        generate(params[:page], params[:per_page])
    end
  end

  def history
    extract_checklist_params
    if params[:format] == 'pdf'
      download_path = PdfChecklistHistory.new(@checklist_params).generate

      send_file(download_path,
        :filename => "history_of_CITES_listings.pdf",
        :type => :pdf)

      # Clean up after ourselves
      FileUtils.rm download_path
    else
      render :json => ChecklistHistory.new(@checklist_params).
        generate(params[:page], params[:per_page])
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
        [
          (params[:show_english] == '1' ? 'E' : nil),
          (params[:show_spanish] == '1' ? 'S' : nil),
          (params[:show_french] == '1' ? 'F' : nil)
        ].compact,
      :synonyms => params[:show_synonyms] == '1'
    }
  end

end
