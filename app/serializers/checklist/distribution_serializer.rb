class Checklist::DistributionSerializer < ActiveModel::Serializer
  attributes :geo_entity_id, :tag_names

  def tag_names
    object.tags.map(&:name)
  end
end
