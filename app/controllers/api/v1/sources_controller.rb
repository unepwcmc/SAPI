class Api::V1::SourcesController < ApplicationController
  caches_action :index
  def index
    locale = params['locale'] || I18n.locale
    debugger
    @sources = Source.all(:order => "name_#{locale}")
    render :json => @sources,
      :each_serializer => Species::SourceSerializer,
      :meta => {:total => @sources.count}
  end
end
