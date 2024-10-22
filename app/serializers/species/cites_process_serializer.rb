class Species::CitesProcessSerializer < ActiveModel::Serializer
  attributes :resolution, { start_date_formatted: :start_date }, :document,
    :document_title, :notes, :geo_entity, :status, :start_event_name

  def start_event_name
    object.start_event.try(:name)
  end
end
