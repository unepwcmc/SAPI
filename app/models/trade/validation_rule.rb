class Trade::ValidationRule < ActiveRecord::Base
  include PgArrayParser
  def column_names
    parse_pg_array(read_attribute(:column_names))
  end
end
