class Trade::InclusionValidationRuleSerializer < Trade::ValidationRuleSerializer
  attributes :valid_values_view, :scope

  def scope
    object.sanitized_sandbox_scope.map do |k, v|
      "#{k} = #{v ? v : 'NULL'}"
    end
  end
end
