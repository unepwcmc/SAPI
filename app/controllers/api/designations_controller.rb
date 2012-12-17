class Api::DesignationsController < ApplicationController
  respond_to :json
  inherit_resources

  protected

  def collection
    @designations ||= end_of_association_chain.order(:name).select([:id, :name]).map{|d| {value: d.id, text: d.name}}
  end
end
