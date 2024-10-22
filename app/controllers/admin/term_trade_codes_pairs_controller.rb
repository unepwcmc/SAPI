class Admin::TermTradeCodesPairsController < Admin::StandardAuthorizationController
  before_action :load_term_codes, only: [ :index, :create ]
  before_action :load_trade_code_types, only: [ :index, :create ]

  def index
    load_associations
    @custom_title = custom_title
    @custom_btn_title = "Add new #{custom_title.singularize}"
    index!
  end

  def destroy
    @term_trade_codes_pair = TermTradeCodesPair.find params[:id]
    destroy! do |format|
      format.html do
        redirect_to admin_term_trade_codes_pairs_path(type: @term_trade_codes_pair.trade_code_type)
      end
    end
  end

protected

  def custom_title
    if params[:type] == 'Unit'
      'Term Unit Pairs'
    elsif params[:type] == 'Purpose'
      'Term Purpose Pairs'
    end
  end

  def load_term_codes
    @term_codes_obj = Term.select([ :id, :code ]).
      map { |c| { 'id' => c.id, 'code' => c.code } }.to_json
  end

  def load_trade_code_types
    @trade_code_type = params[:type] ||
      (params[:term_trade_codes_pair] && params[:term_trade_codes_pair][:trade_code_type]) ||
      'Unit'
    @trade_code_codes = TradeCode.where(type: @trade_code_type).
      select([ :id, :code ]).order('code')
    @trade_code_codes_obj = @trade_code_codes.map { |c| { 'value' => c.id, 'text' => c.code } }.to_json
  end

  def collection
    @term_trade_codes_pairs ||= end_of_association_chain.where(
      trade_code_type: @trade_code_type
    ).order(
      'term_id'
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

private

  def term_trade_codes_pair_params
    params.require(:term_trade_codes_pair).permit(
      :trade_code_id, :trade_code_type, :term_id
    )
  end
end
