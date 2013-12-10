class Api::V1::PurposesController < ApplicationController
  caches_action :index
  def index
    locale = params['locale'] || I18n.locale
    @purposes = Purpose.all(:order => "name_#{locale}")
    render :json => @purposes,
      :each_serializer => Species::PurposeSerializer,
      :meta => {:total => @purposes.count}
  end
end
