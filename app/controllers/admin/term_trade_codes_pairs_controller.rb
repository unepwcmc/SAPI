class Admin::TermTradeCodesPairsController < Admin::SimpleCrudController
  inherit_resources

  before_filter :load_trade_code_types, :only => [:index, :create]
  defaults :resource_class => TermTradeCodesPair, 
    :collection_name => 'term_trade_codes_pairs', :instance_name => 'term_trade_codes_pair'

  def index
    super
  end

  protected

  def load_trade_code_types
    @trade_code_type = params[:type] || 'Unit'
    @trade_code_codes = TradeCode.where(:type => @trade_code_type).
      select([:id, :code]).order('code')
    @trade_code_codes_arr = @trade_code_codes.map { |c| [c.code, c.id] }
    @trade_code_codes_obj = @trade_code_codes.map { |c| {"value" => c.id, "text" => c.code} }.to_json

  end

  def collection
    @term_trade_codes_pairs ||= end_of_association_chain.
      where(:trade_code_type => @trade_code_type).
      order('term_id').
      page(params[:page])
  end
end