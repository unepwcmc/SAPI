class Api::TermsController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    @term = Term.new(params[:term])
    if @term.save
      render :json => @term
    else
      render :json => {:errors => @term.errors}
    end
  end
end