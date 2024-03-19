##
# This module is intended to apply to ActiveRecord::Base subclasses (and is in
# fact applied to ApplicationRecord, primarily to provide helper method
# `duplicates`, which finds
#
# The following methods should return Arrays of symbols, and can be overridden
# to customise what should count for the purpose of calculating duplication:
#
# - text_attributes (class method)
# - ignored_attributes (class method)
# - comparison_attributes

module ComparisonAttributes
  extend ActiveSupport::Concern

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def ignored_attributes
      attr_to_ignore = [:id, :created_at, :updated_at, :created_by_id, :updated_by_id, :original_id]
      # When upgrade `acts_as_taggable` gem from version 5 to 8.1, we found that
      #  `attributes` now return `xxx_list` as well. Put them in ignore list.
      # `ignored_attributes` is used by ComparisonAttributes when identifying
      # duplicate records. Attributes in this list won't be considered when
      # determining if the record is a duplicate.
      attr_to_ignore += tag_types.map{|t| "#{t.to_s.singularize}_list" } if taggable?
      attr_to_ignore
    end

    def text_attributes
      []
    end
  end

  # Returns an array of symbols, listing all the model's columns except
  # those in `class.ignored_attributes`. These are the columns which will be
  # used to determine if two rows are is similar.
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
        # if it is, it checks the array length (note that an empty array has a length of NULL),
        # otherwise, it will perform an array equality check.
        # I had to transform all the queries into strings because I couldn't find a proper way
        # to do this using Arel.
        elsif attr_val.is_a?(Array)
          if attr_val.compact.length > 0
            %Q("#{a.table_name}"."#{attr_name}" = ARRAY[#{attr_val.join(',')}]::INTEGER[])
          else
            # array_length(array, 1) checks the length of the topmost level of
            # an array (which might be multidimensional)
            # array_length('{}'::int[], 1) returns NULL, not 0.
            Arel::Nodes::NamedFunction.new(
              'ARRAY_LENGTH', [a.table[attr_name], 1]
            ).eq(nil).to_sql
          end
        else
          a.table[attr_name].eq(attr_val).to_sql
        end
    end
    arel_nodes.join(' AND ')
  end

  # This method operates on a database row and returns a relation representing
  # all those rows in the same table which are duplicates, defined as rows where
  # all columns in `comparison_attributes` match.
  #
  # If the parameter comparison_attributes_override is provided (which should
  # be a hash of key-value pairs), the values in that hash are used in preference
  # to those of the `self` row, e.g.:
  #
  # ```
  # if row.duplicates({ parent_id: new_parent_id })
  #   raise "Cannot reassign row #{row.id} from parent #{row.parent_id} to #{new_parent_id} - duplicate exists"
  # end
  # ```
  #
  # This is used heavily in code relating to nomenclature changes.
  def duplicates(comparison_attributes_override)
    self.class.where(
      comparison_conditions(
        comparison_attributes.merge(comparison_attributes_override.symbolize_keys)
      )
    )
  end

end

# ApplicationRecord.send :include, ComparisonAttributes

# Since Rails 5, our base class has changed and is no longer ActiveRecord::Base,
# but is now ApplicationRecord. However ActsAsTaggableOn still has
# ActiveRecord::Base as a base class, therefore it needs to be done separately.
# It's possible that more ActsAsTaggableOn:: classes need this treatment.
# ActsAsTaggableOn::Tagging.send :include, ComparisonAttributes
