class Api::V1::UnitsController < ApplicationController
  caches_action :index
  def index
    @units = Unit.all
    render :json => @units,
      :each_serializer => Species::UnitSerializer,
      :meta => {:total => @units.count}
  end
end
