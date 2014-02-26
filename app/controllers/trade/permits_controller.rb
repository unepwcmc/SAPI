class Trade::PermitsController < TradeController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :permit_sweeper

  def index
    matcher = Trade::PermitMatcher.new(params)
    render :json => matcher.results,
      :each_serializer => Trade::PermitSerializer,
      :meta => {
        :total => matcher.total_cnt,
        :page => matcher.page,
        :per_page => matcher.per_page
      }
  end

end
