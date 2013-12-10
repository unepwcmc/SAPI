class Api::V1::SourcesController < ApplicationController
  caches_action :index
  def index
    @sources = Source.all(:order => "name_#{params['locale']}")
    render :json => @sources,
      :each_serializer => Species::SourceSerializer,
      :meta => {:total => @sources.count}
  end
end
