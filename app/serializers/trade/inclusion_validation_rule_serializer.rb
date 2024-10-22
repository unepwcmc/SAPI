# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  column_names      :string(255)      is an Array
#  format_re         :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  is_strict         :boolean          default(FALSE), not null
#  run_order         :integer          not null
#  scope             :hstore
#  type              :string(255)      not null
#  valid_values_view :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Trade::InclusionValidationRuleSerializer < Trade::ValidationRuleSerializer
  attributes :valid_values_view, :scope

  def scope
    object.sanitized_sandbox_scope.map do |k, v|
      "#{k} = #{v ? v : 'NULL'}"
    end
  end
end
