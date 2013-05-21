class Trade::ValidationRulesController < ApplicationController
  respond_to :json

  def index
    respond_with Trade::ValidationRule.all
  end
end
