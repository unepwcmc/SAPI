class Admin::EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :effective_at_formatted
end
