class Admin::StatisticsController < ApplicationController

  def index
    @stats = SapiModule::Summary.database_stats
  end
end
