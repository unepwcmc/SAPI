class CountryDictionary
  include Singleton

  def initialize
    @collection = GeoEntity.
      select([
        :"geo_entities.id", :name_en, :name_es, :name_fr,
        :"UPPER(geo_entities.iso_code2) AS iso_code2"
      ]).
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => [GeoEntityType::COUNTRY, GeoEntityType::TERRITORY]).
      all
    @dictionary = Hash[
      @collection.map { |c| [c.id, [c.name, c.iso_code2]] }
    ]
  end

  def get_iso_code_by_id(id)
    country = @dictionary[id.to_i]
    country && country.last || nil
  end

  def get_name_by_id(id)
    country = @dictionary[id.to_i]
    country && country.first || nil
  end

  def get_iso_codes_by_ids(ids_ary)
    ids_ary.map { |id| get_iso_code_by_id(id) }
  end

  def get_names_by_ids(ids_ary)
    ids_ary.map { |id| get_name_by_id(id) }
  end

end
