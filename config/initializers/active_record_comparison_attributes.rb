module ComparisonAttributes

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def ignored_attributes
      [:id, :created_at, :updated_at, :created_by_id, :updated_by_id, :original_id]
    end

    def text_attributes
      []
    end
  end

  def comparison_attributes
    attributes.except(*self.class.ignored_attributes.map(&:to_s)).symbolize_keys
  end

  def comparison_conditions(comparison_attributes = nil)
    comparison_attributes ||= self.comparison_attributes
    a = self.class.all
    arel_nodes = []
    comparison_attributes.each do |attr_name, attr_val|
      arel_nodes <<
        if self.class.text_attributes.include? attr_name
          Arel::Nodes::NamedFunction.new('SQUISH_NULL', [a.table[attr_name]]).
            eq(attr_val.presence).to_sql
        # ActiveRecord 4 saves arrays as '[]' instead of using the postgres notation '{}'
        # Also, Arel doesn't seem to be able to manage the comparison when passing '[]' in 'eq'
        # The workaround below checks if the attribute value is an empty array,
        # if it is it checks if the length is 0,
        # otherwise, it will perform an array equality check.
        # I had to transform all the queries into strings because I couldn't find a proper way
        # to do this using Arel.
        elsif attr_val.is_a?(Array)
          if attr_val.length > 0
            %Q("#{a.table_name}"."#{attr_name}" = ARRAY[#{attr_val.join(',')}])
          else
            Arel::Nodes::NamedFunction.new('ARRAY_LENGTH', [a.table[attr_name], 1]).
              eq(0).to_sql
          end
        else
          a.table[attr_name].eq(attr_val).to_sql
        end
    end
    arel_nodes.join(' AND ')
  end

  def duplicates(comparison_attributes_override)
    self.class.where(
      comparison_conditions(
        comparison_attributes.merge(comparison_attributes_override.symbolize_keys)
      )
    )
  end

end

ActiveRecord::Base.send :include, ComparisonAttributes
