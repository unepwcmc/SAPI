module ComparisonAttributes

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def ignored_attributes
      [:id, :created_at, :updated_at]
    end
  end

  def comparison_attributes
    attributes.except(*self.class.ignored_attributes.map(&:to_s))
  end

  def duplicates(comparison_attributes_override)
    self.class.where(comparison_attributes.merge(comparison_attributes_override))
  end

end

ActiveRecord::Base.send :include, ComparisonAttributes
