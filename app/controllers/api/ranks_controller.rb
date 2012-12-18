class Api::RanksController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @rank }
      failure.json { render :json => { :errors => @rank.errors } }
    end
  end

  protected

  def collection
    @ranks ||= end_of_association_chain.
      select([:id, :name]).
      map{|d| {:value => d.id, :text => d.name}}
  end
end
