class Species::QuotaSerializer < ActiveModel::Serializer
  attributes :quota, :start_date, :publication_date,
    :notes, :url, :public_display
end
