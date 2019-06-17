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

class TradeCode < ActiveRecord::Base
  attr_accessible :code, :type,
    :name_en, :name_es, :name_fr
  translates :name

  validates :code, :presence => true, :uniqueness => { :scope => :type }

  def self.search(query)
    if query.present?
      where("UPPER(code) LIKE UPPER(:query)
            OR UPPER(name_en) LIKE UPPER(:query)
            OR UPPER(name_fr) LIKE UPPER(:query)
            OR UPPER(name_es) LIKE UPPER(:query)",
            :query => "%#{query}%")
    else
      all
    end
  end

end
