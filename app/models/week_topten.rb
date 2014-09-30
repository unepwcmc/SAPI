class WeekTopten

  def initialize(start_date)
    @start_date = start_date
  end

  def data
    Ahoy::Event
      .select("properties ->>'full_name' as species, count(*)")
      .where("name='Taxon Concept' and time between '#{@start_date}' and date '#{@start_date}' + 7")
      .group('species')
      .order('COUNT DESC')
      .limit(10)
  end 
end
