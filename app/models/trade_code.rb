class TradeCode < ActiveRecord::Base
  attr_accessible :code, :type, :name_en, :name_es, :name_fr,
    :description_en, :description_es, :description_fr
  translates :name, :description

  validates :code, :presence => true, :uniqueness => {:scope => :type}
end
