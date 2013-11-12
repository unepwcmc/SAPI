class Trade::PermitMatcher
  attr_accessor :page, :per_page

  def initialize(options)
    initialize_options(options)
    initialize_query
  end

  def results
    @query.limit(@per_page).offset(@per_page * (@page - 1)).all
  end

  def total_cnt
    @query.count
  end

  private

  def initialize_options(options)
    @page = options[:page] || 1
    @per_page = 25
    @permit_query = options[:permit_query] && options[:permit_query].upcase.strip
  end

  def initialize_query
    @query = Trade::Permit.scoped
    if @permit_query
      @query = @query.where([
        "UPPER(number) LIKE :number", :number => "#{@permit_query}%"
      ])
    end
  end

end

