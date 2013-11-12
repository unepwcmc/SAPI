class Api::V1::TermsController < ApplicationController
  caches_action :index
  def index
    @terms = Term.all
    render :json => @terms,
      :each_serializer => Species::TermSerializer,
      :meta => {:total => @terms.count}
  end
end
