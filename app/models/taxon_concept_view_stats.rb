class TaxonConceptViewStats

  def initialize(start_date, end_date, taxonomy = Taxonomy::CITES_EU)
    @start_date = start_date
    @end_date = end_date
    @taxonomy = taxonomy
  end

  def results
    query.limit(10)
  end

  private

  def query
    Ahoy::Event.select(<<-SQL
      properties->>'id' AS tc_id,
      properties ->>'full_name' AS tc_full_name,
      COUNT(*) AS number_of_visits
    SQL
    ).
    where(name: 'Taxon Concept').
    where(['time > ? AND time <= ?', @start_date, @end_date]).
    where(["properties->>'taxonomy_name' = ?", @taxonomy]).
    group("properties->>'id', properties->>'full_name'").
    order('number_of_visits DESC')
  end

end
