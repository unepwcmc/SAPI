class Api::V1::UnitsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c|
      {:locale => "en"}.merge(c.params.select{|k,v| "locale" == k})
    }
  def index
    @units = Unit.all
    render :json => @units,
      :each_serializer => Species::UnitSerializer,
      :meta => {:total => @units.count}
  end
end
