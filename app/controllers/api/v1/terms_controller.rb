class Api::V1::TermsController < ApplicationController
  caches_action :index
  def index
    locale = params['locale'] || I18n.locale
    @terms = Term.all(:order => "name_#{locale}")
    render :json => @terms,
      :each_serializer => Species::TermSerializer,
      :meta => {:total => @terms.count}
  end
end
