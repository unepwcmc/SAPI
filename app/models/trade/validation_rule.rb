# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  column_names      :string(255)      not null
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#

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
