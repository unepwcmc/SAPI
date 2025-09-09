class Trade::PermitMatcher
  attr_accessor :page, :per_page

  def initialize(options)
    initialize_options(options)
    initialize_query
  end

  def results
    @query.limit(@per_page).offset(@per_page * (@page - 1)).to_a
  end

  def total_cnt
    @query.count
  end

private

  def initialize_options(options)
    @page = options[:page] || 1
    @per_page = 25
    @permit_query = options[:permit_query] &&
      sanitize_permit_query(options[:permit_query])
  end

  def initialize_query
    # Better matches are shorter, (e.g. 100 matches 100 and 1000)
    @query = Trade::Permit.order('length(number)', :number)

    if @permit_query
      @query = @query.where(
        [
          'number LIKE :number',
          number: "%#{Trade::Permit.sanitize_sql_like(@permit_query).upcase}%"
        ]
      )
    end
  end

  def sanitize_permit_query(query)
    # negative limit does not suppress trailing nulls
    query_parts =
      query.upcase.strip.split('%', -1).map do |qp|
        if qp.blank?
          '%' # replace the wildcard
        else
          ApplicationRecord.connection.quote_string(qp)
        end
      end
    query_parts.join
  end
end
