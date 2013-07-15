class Species::EventSerializer < ActiveModel::Serializer
  attributes :name, :effective_at_formatted
end
