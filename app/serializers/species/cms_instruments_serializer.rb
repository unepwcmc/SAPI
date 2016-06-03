class Species::CmsInstrumentsSerializer < ActiveModel::Serializer
  attributes :effective_from_formatted, :name

  def name
    object.instrument.name
  end
end
