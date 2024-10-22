# == Schema Information
#
# Table name: trade_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)      not null
#  name_en    :string(255)      not null
#  type       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name_es    :string(255)
#  name_fr    :string(255)
#

class TradeCode < ApplicationRecord
  extend Mobility
  # Migrated to controller (Strong Parameters)
  # attr_accessible :code, :type, :name_en, :name_es, :name_fr
  translates :name

  has_many :taxon_concept_term_pairs,
    class_name: 'Trade::TaxonConceptTermPair',
    foreign_key: :term_id,
    dependent: :restrict_with_error

  has_many :term_trade_codes_pairs, dependent: :restrict_with_error
  validates :code, presence: true, uniqueness: { scope: :type }

  def self.search(query)
    return all if query.blank?

    self.ilike_search(
      query, [
        :code,
        :name_en,
        :name_es,
        :name_fr
      ]
    )
  end
end
