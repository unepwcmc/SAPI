class ExportsController < ApplicationController
  
  layout "admin"

  # GET exports/
  #
  def index
    @designations = Designation.order('name')
  end

  def download
    if params[:data_type] == 'Q'
      send_file Quota.to_csv, :filename => 'quotas.csv',
        :type => 'csv'
    end
  end
end
