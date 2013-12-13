class Api::V1::SourcesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  def index
    @sources = Source.all(:order => "code")
    render :json => @sources,
      :each_serializer => Species::SourceSerializer,
      :meta => {:total => @sources.count}
  end
end
