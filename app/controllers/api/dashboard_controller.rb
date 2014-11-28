class Api::DashboardController < ApplicationController
  before_filter :authenticate_user!
  layout 'pages'

  def index
  end
end
