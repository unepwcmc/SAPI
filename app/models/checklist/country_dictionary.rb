class Checklist::CountryDictionary
  include Singleton

  def initialize
    @collection = GeoEntity.
      select([:"geo_entities.id", :"geo_entities.name", :"geo_entities.iso_code2"]).
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => GeoEntityType::COUNTRY).
      all
    @dictionary = Hash[
      @collection.map { |c| [c.id, [c.name, c.iso_code2] ] }
    ]
    puts @dictionary.inspect
  end
  def getIsoCodeById(id)
    country = @dictionary[id.to_i]
    country && country.last || nil
  end
  def getNameById(id)
    country = @dictionary[id.to_i]
    country && country.first || nil
  end
end