# == Schema Information
#
# Table name: term_trade_codes_pairs
#
#  id              :integer          not null, primary key
#  term_id         :integer          not null
#  trade_code_id   :integer
#  trade_code_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TermTradeCodesPair < ActiveRecord::Base
  attr_accessible :trade_code_id, :trade_code_type, :term_id

  belongs_to :term, :class_name => "TradeCode"
  belongs_to :trade_code

  validates :term_id, :presence => true, :uniqueness => { :scope => :trade_code_id }

  def self.search(query)
    if query.present?
      where("UPPER(trade_codes.code) LIKE UPPER(:query)
            OR UPPER(terms.code) LIKE UPPER(:query)",
            :query => "%#{query}%").
      joins(<<-SQL
          LEFT JOIN trade_codes
            ON trade_codes.id = term_trade_codes_pairs.trade_code_id
          LEFT JOIN trade_codes terms
            ON terms.id = term_trade_codes_pairs.term_id
        SQL
      )
    else
      all
    end
  end
end
