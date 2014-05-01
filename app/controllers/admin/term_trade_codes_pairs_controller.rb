class Admin::TermTradeCodesPairsController < Admin::SimpleCrudController
  inherit_resources

  before_filter :load_term_codes, :only => [:index, :create]
  before_filter :load_trade_code_types, :only => [:index, :create]
  defaults :resource_class => TermTradeCodesPair, 
    :collection_name => 'term_trade_codes_pairs', :instance_name => 'term_trade_codes_pair'

  protected

  def load_term_codes
    @term_codes_obj = Term.select([:id, :code]).
      map { |c| {"id" => c.id, "code" => c.code} }.to_json
  end

  def load_trade_code_types
    @trade_code_type = params[:type] ||
      params[:term_trade_codes_pair] && params[:term_trade_codes_pair][:trade_code_type] ||
      'Unit'
    @trade_code_codes = TradeCode.where(:type => @trade_code_type).
      select([:id, :code]).order('code')
    @trade_code_codes_obj = @trade_code_codes.map { |c| {"value" => c.id, "text" => c.code} }.to_json
  end

  def collection
    @term_trade_codes_pairs ||= end_of_association_chain.
      where(:trade_code_type => @trade_code_type).
      order('term_id').
      page(params[:page]).
      search(params[:query])
  end
end