class DashboardStats

  include ActiveModel::Serializers::JSON

  def initialize (iso_code, kingdom)
    @iso_code = iso_code
    @kingdom = kingdom || 'Animalia'
    @geo_entity = GeoEntity.where(:iso_code2 => iso_code).first
  end

  def get_geo_entity
    @geo_entity
  end

  def get_kingdom
    @kingdom
  end

  def get_species_classes taxonomy
    taxonomy_id = Taxonomy.where(:name => taxonomy.upcase).select('id').first
    MTaxonConcept.where(
      :rank_name => 'CLASS', :kingdom_name => @kingdom, :taxonomy_id => taxonomy_id).
      select([:class_name, :english_names_ary]).uniq.
      map do |s| 
        {:name => s.class_name, :common_name_en => s.english_names.first}
      end
  end

  def species
    species_results = {}
    [:cites_eu, :cms].each do |taxonomy|
      species_results[taxonomy] = []
      get_species_classes(taxonomy).each do |species_class|
        taxonomy_is_cites_eu = taxonomy == :cites_eu ? 't' : 'f'
        search = MTaxonConcept.where(
          "taxonomy_is_cites_eu = '#{taxonomy_is_cites_eu}'
          AND class_name = '#{species_class[:name]}'
          AND countries_ids_ary && ARRAY[#{@geo_entity.id}]")
        result = { 
          :name => species_class[:name],
          :common_name_en => species_class[:common_name_en],
          :count => search.count
        }
        species_results[taxonomy] << result
      end
    end
    species_results
  end

  def trade
    trade_results = {}
    exports = Trade::ShipmentView.where(
      :importer_id => @geo_entity.id
    ).count
    trade_results['exports'] = exports
    imports = Trade::ShipmentView.where(
      :exporter_id => @geo_entity.id
    ).count
    trade_results['imports'] = imports
    trade_results
  end

end