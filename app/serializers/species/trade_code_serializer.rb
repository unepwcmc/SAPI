class Species::TradeCodeSerializer < ActiveModel::Serializer
  attributes :id, :code, :name_en
end
