class ExportsController < ApplicationController
  layout "admin"

  # GET exports/
  #
  def index
    @designations = Designation.order('name')
  end

  def download
    if params[:data_type] == 'Q'
      result = Quota.export
      send_file result[0], result[1]
    end
  end
end
