class Api::RanksController < ApplicationController
  respond_to :json
  inherit_resources

  protected

  def collection
    @ranks ||= end_of_association_chain.
      select([:id, :name]).
      map { |d| { :value => d.id, :text => d.name } }
  end
end
