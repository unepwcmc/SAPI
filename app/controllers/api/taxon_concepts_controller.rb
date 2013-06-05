class Api::TaxonConceptsController < ApplicationController

  def index
    @search = case params[:search_type]
      when 'checklist' then Checklist::Checklist.new(params)
      else Species::Search.new(params)
    end
    render :json => @search.generate(params[:page], params[:per_page])
  end

end
