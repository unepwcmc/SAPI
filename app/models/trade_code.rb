class TradeCode < ActiveRecord::Base
  attr_accessible :code, :name, :type
end

class Term < TradeCode; end
class Unit < TradeCode; end
class Purpose < TradeCode; end
class Source < TradeCode; end
