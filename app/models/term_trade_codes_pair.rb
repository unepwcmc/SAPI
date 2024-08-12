# == Schema Information
#
# Table name: term_trade_codes_pairs
#
#  id              :integer          not null, primary key
#  trade_code_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  term_id         :integer          not null
#  trade_code_id   :integer
#
# Indexes
#
#  index_term_trade_codes_pairs_on_term_and_trade_code  (term_id,trade_code_id,trade_code_type) UNIQUE
#
# Foreign Keys
#
#  term_trade_codes_pairs_term_id_fk        (term_id => trade_codes.id)
#  term_trade_codes_pairs_trade_code_id_fk  (trade_code_id => trade_codes.id)
#

class TermTradeCodesPair < ApplicationRecord
  # Migrated to controller (Strong Parameters)
  # attr_accessible :trade_code_id, :trade_code_type, :term_id

  belongs_to :term, class_name: 'TradeCode'
  belongs_to :trade_code, optional: true

  validates :term_id, uniqueness: { scope: :trade_code_id }

  def self.search(query)
    if query.present?
      where("UPPER(trade_codes.code) LIKE UPPER(:query)
            OR UPPER(terms.code) LIKE UPPER(:query)",
        query: "%#{query}%").
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
