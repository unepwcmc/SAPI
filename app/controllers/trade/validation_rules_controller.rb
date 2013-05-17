class Trade::ValidationRulesController < ApplicationController
  respond_to :json

  def index
    respond_with Trade::ValidationRule.limit(10)
    #render :text => {:validation_rules => Trade::ValidationRule.all}.to_json
    #render :text => {:validation_rules => [{:id => 2, :type => 'Trade::PresenceValidationRule', :column_names => [:appendix_no]}]}
    #render :text => '{"validation_rules": [{"id": 2, "type": "Trade::PresenceValidationRule", "column_names": "{appendix_no}"}]}'
  end
end
