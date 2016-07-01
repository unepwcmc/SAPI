class Species::EmberController < ApplicationController
  layout 'species'
  def start
    respond_to do |format|
      format.html {}
    end
  end
end
