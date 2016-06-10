class GeoEntitySearch
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt

  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def results
    @query.reload
  end

  private

  def initialize_params(options)
    @geo_entity_types_set = GeoEntityType::SETS.key?(
      options[:geo_entity_types_set]
      ) &&
      options[:geo_entity_types_set] ||
      GeoEntityType::DEFAULT_SET
    @locale =
      if options[:locale] &&
        ['en', 'es', 'fr'].include?(options[:locale].downcase)
        options[:locale]
      else
        I18n.locale
      end
    @options = {
      geo_entity_types_set: @geo_entity_types_set,
      locale: @locale
    }
  end

  def initialize_query
    geo_entity_types = GeoEntityType::SETS[@geo_entity_types_set]
    @query = GeoEntity.
      joins(:geo_entity_type).
      includes(:geo_entity_type).
      order("name_#{@locale}")
    if GeoEntityType::CURRENT_ONLY_SETS.include?(@geo_entity_types_set)
      @query = @query.current
    end
    unless geo_entity_types.empty?
      @query = @query.
        where('geo_entity_types.name' => geo_entity_types)
    end
  end
end
