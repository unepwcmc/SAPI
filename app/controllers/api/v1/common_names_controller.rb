class Api::V1::CommonNamesController < ApplicationController
  
  def show
    render :json => CommonName.find(params[:id]),
      :serializer => Species::CommonNameSerializer
  end
end

