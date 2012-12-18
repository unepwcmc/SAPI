class Api::TradeCodesController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @trade_code }
      failure.json { render :json => { :errors => @trade_code.errors } }
    end
  end

end
