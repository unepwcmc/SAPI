class Api::SourcesController < Api::TradeCodesController
  respond_to :json
  inherit_resources
end