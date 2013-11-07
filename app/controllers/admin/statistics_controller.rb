class Admin::StatisticsController < ApplicationController

  def index
    @stats = Sapi::Summary.database_stats
  end
end
