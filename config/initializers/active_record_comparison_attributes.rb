module ComparisonAttributes

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def ignored_attributes
      [:id, :created_at, :updated_at, :created_by_id, :updated_by_id, :original_id]
    end

    def text_attributes; []; end
  end

  def comparison_attributes
    attributes.except(*self.class.ignored_attributes.map(&:to_s)).symbolize_keys
  end

  def comparison_conditions(comparison_attributes = nil)
    comparison_attributes ||= self.comparison_attributes
    a = self.class.scoped
    arel_nodes = []
    comparison_attributes.each do |attr_name, attr_val|
      arel_nodes <<
        if self.class.text_attributes.include? attr_name
          Arel::Nodes::NamedFunction.new('SQUISH_NULL', [a.table[attr_name]]).
          eq(attr_val.presence)
        else
          a.table[attr_name].eq(attr_val)
        end
    end
    arel_nodes.inject(&:and)
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
