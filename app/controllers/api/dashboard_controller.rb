class Api::DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
  end
end
