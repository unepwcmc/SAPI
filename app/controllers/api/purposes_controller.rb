class Api::PurposesController < Api::TradeCodesController
  respond_to :json
  inherit_resources
end