class Trade::ValidationRule < ActiveRecord::Base
  attr_accessible :column_names
  include PgArrayParser

  def column_names
    parse_pg_array(read_attribute(:column_names))
  end
  def column_names=(ary)
    write_attribute(:column_names, '{' + ary.join(',') + '}')
  end
  def matching_records
    raise "Must be implemented in subcass"
  end
end
