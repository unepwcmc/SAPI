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
#  index_term_trade_codes_pairs_on_term_and_trade_code        (term_id,trade_code_id,trade_code_type) UNIQUE
#  index_term_trade_codes_pairs_on_term_id                    (term_id)
#  index_term_trade_codes_pairs_on_term_id_and_trade_code_id  (term_id,trade_code_id) UNIQUE
#  index_term_trade_codes_pairs_on_trade_code_id              (trade_code_id)
#  index_term_trade_codes_pairs_on_trade_code_id_and_term_id  (trade_code_id,term_id) UNIQUE
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
    return all if query.blank?

    self.left_joins([ :term, :trade_code ]).ilike_search(
      query, [
        TradeCode.arel_table['code'],
        Term.arel_table['code']
      ]
    )
  end
end
